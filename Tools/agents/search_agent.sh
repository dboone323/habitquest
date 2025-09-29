#!/bin/bash
# Search Agent: Finds and summarizes information from codebase, docs, or the web as needed

AGENT_NAME="search_agent.sh"
LOG_FILE="$(dirname "$0")/search_agent.log"
QUERY_DIR="/Users/danielstevens/Desktop/Code/Tools/Automation/agents/queries"
STATUS_FILE="$(dirname "$0")/agent_status.json"
CACHE_DIR="$(dirname "$0")/search_cache"
PID=$$

SLEEP_INTERVAL=1800 # 30 minutes
MIN_INTERVAL=300
MAX_INTERVAL=3600

function update_status() {
  local status="$1"
  local timestamp
  timestamp=$(date +%s)

  # Ensure status file exists and is valid JSON
  if [[ ! -s ${STATUS_FILE} ]]; then
    echo '{"agents":{},"last_update":0}' >"${STATUS_FILE}"
  fi

  # Use jq with proper escaping to avoid JSON parsing errors
  if command -v jq &>/dev/null &&
    jq --arg agent "${AGENT_NAME}" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
      '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber)}' \
      "${STATUS_FILE}" >"${STATUS_FILE}.tmp" &&
    [[ -s "${STATUS_FILE}.tmp" ]]; then
    mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
  else
    local current_time
    current_time=$(date)
    echo "[${current_time}] ${AGENT_NAME}: Failed to update status file" >>"${LOG_FILE}"
    rm -f "${STATUS_FILE}.tmp"
  fi
}

mkdir -p "${QUERY_DIR}"
mkdir -p "${CACHE_DIR}"

# Function to get cached search results
get_cached_result() {
  local query="$1"
  local sanitized_query
  sanitized_query="${query//[^a-zA-Z0-9]/_}"
  local cache_file="${CACHE_DIR}/${sanitized_query}.cache"

  if [[ -f ${cache_file} ]]; then
    local cache_age=$(($(date +%s) - $(stat -f %m "${cache_file}" 2>/dev/null || date +%s)))
    # Cache valid for 1 hour (3600 seconds)
    if [[ ${cache_age} -lt 3600 ]]; then
      cat "${cache_file}"
      return 0
    fi
  fi
  return 1
}

# Function to cache search results
cache_result() {
  local query="$1"
  local result="$2"
  local sanitized_query
  sanitized_query="${query//[^a-zA-Z0-9]/_}"
  local cache_file="${CACHE_DIR}/${sanitized_query}.cache"

  echo "${result}" >"${cache_file}"
}

# Function to search codebase
search_codebase() {
  local query="$1"
  local workspace_root="/Users/danielstevens/Desktop/Quantum-workspace"

  echo "[$(date)] ${AGENT_NAME}: Searching codebase for '${query}'" >>"${LOG_FILE}"
  echo "[Codebase Search] Results for '${query}':" >>"${LOG_FILE}"

  # Search in source code files
  local results
  results=$(find "${workspace_root}" -type f \( -name "*.swift" -o -name "*.py" -o -name "*.sh" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.cpp" -o -name "*.h" \) \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.build/*" \
    -not -path "*/DerivedData/*" \
    -exec grep -l "${query}" {} \; 2>/dev/null | head -10)

  if [[ -n ${results} ]]; then
    echo "${results}" | while read -r file; do
      local rel_path="${file#"${workspace_root}"/}"
      local line_count
      line_count=$(grep -c "${query}" "${file}" 2>/dev/null || echo "0")
      echo "  📄 ${rel_path} (${line_count} matches)" >>"${LOG_FILE}"

      # Show context for first match
      local context
      context=$(grep -n -A2 -B2 "${query}" "${file}" 2>/dev/null | head -10)
      if [[ -n ${context} ]]; then
        echo "    Context:" >>"${LOG_FILE}"
        echo "${context}" | awk '{print "      " $0}' >>"${LOG_FILE}"
      fi
    done
  else
    echo "  No matches found in codebase" >>"${LOG_FILE}"
  fi
}

# Function to search documentation
search_documentation() {
  local query="$1"
  local workspace_root="/Users/danielstevens/Desktop/Quantum-workspace"

  echo "[$(date)] ${AGENT_NAME}: Searching documentation for '${query}'" >>"${LOG_FILE}"
  echo "[Documentation Search] Results for '${query}':" >>"${LOG_FILE}"

  # Search in documentation files
  local results
  results=$(find "${workspace_root}" -type f \( -name "*.md" -o -name "README*" -o -name "*.txt" -o -name "*.rst" \) \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -exec grep -l "${query}" {} \; 2>/dev/null | head -5)

  if [[ -n ${results} ]]; then
    echo "${results}" | while read -r file; do
      local rel_path="${file#"${workspace_root}"/}"
      local line_count
      line_count=$(grep -c "${query}" "${file}" 2>/dev/null || echo "0")
      echo "  📚 ${rel_path} (${line_count} matches)" >>"${LOG_FILE}"

      # Show relevant sections
      local sections
      sections=$(grep -A5 -B1 "${query}" "${file}" 2>/dev/null | head -15)
      if [[ -n ${sections} ]]; then
        echo "    Relevant content:" >>"${LOG_FILE}"
        echo "${sections}" | awk '{print "      " $0}' >>"${LOG_FILE}"
      fi
    done
  else
    echo "  No matches found in documentation" >>"${LOG_FILE}"
  fi
}

# Function to search web (if available)
search_web() {
  local query="$1"

  echo "[$(date)] ${AGENT_NAME}: Searching web for '${query}'" >>"${LOG_FILE}"
  echo "[Web Search] Results for '${query}':" >>"${LOG_FILE}"

  # Check cache first
  if cached_result=$(get_cached_result "${query}") && [[ -n ${cached_result} ]]; then
    echo "  💾 Using cached results:" >>"${LOG_FILE}"
    echo "${cached_result}" >>"${LOG_FILE}"
    return 0
  fi

  local all_results=""

  if command -v curl &>/dev/null; then
    # Try DuckDuckGo instant answers first (lightweight)
    local search_url="https://api.duckduckgo.com/?q=${query}&format=json&no_html=1&skip_disambig=1"
    if response=$(curl -s --max-time 10 "${search_url}" 2>/dev/null) && [[ -n ${response} ]]; then
      local instant_answer
      instant_answer=$(echo "${response}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    results = []

    # Extract instant answer
    if data.get('Answer'):
        results.append(('Answer', data['Answer'][:300] + '...' if len(data['Answer']) > 300 else data['Answer']))

    # Extract abstract
    if data.get('AbstractText'):
        results.append(('Abstract', data['AbstractText'][:300] + '...' if len(data['AbstractText']) > 300 else data['AbstractText']))

    # Extract related topics
    if data.get('RelatedTopics'):
        topics = data.get('RelatedTopics', [])
        if isinstance(topics, list) and len(topics) > 0:
            for i, topic in enumerate(topics[:3]):  # Limit to 3 topics
                if isinstance(topic, dict) and topic.get('Text'):
                    results.append((f'Related {i+1}', topic['Text'][:200] + '...' if len(topic['Text']) > 200 else topic['Text']))

    # Print results
    for title, content in results:
        print(f'{title}: {content}')

except Exception as e:
    print(f'Error parsing response: {e}')
" 2>/dev/null)

      if [[ -n ${instant_answer} ]]; then
        echo "${instant_answer}" | while IFS=':' read -r title content; do
          echo "  🌐 ${title}: ${content}" >>"${LOG_FILE}"
        done
      fi
    fi

    # Try additional web search methods if DuckDuckGo didn't give good results
    if [[ -z ${instant_answer} ]] || [[ $(echo "${instant_answer}" | wc -l) -lt 2 ]]; then
      # Try searx (privacy-focused search engine) if available
      local searx_url="https://searx.org/search?q=${query}&format=json"
      if searx_response=$(curl -s --max-time 15 "${searx_url}" 2>/dev/null) && [[ -n ${searx_response} ]]; then
        local searx_results
        searx_results=$(echo "${searx_response}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    results = data.get('results', [])[:3]  # Limit to 3 results

    for result in results:
        title = result.get('title', '')[:50] + '...' if len(result.get('title', '')) > 50 else result.get('title', '')
        url = result.get('url', '')
        content = result.get('content', '')[:150] + '...' if len(result.get('content', '')) > 150 else result.get('content', '')
        print(f'{title} | {url} | {content}')
except:
    pass
" 2>/dev/null)

        if [[ -n ${searx_results} ]]; then
          echo "  🔍 Additional web results:" >>"${LOG_FILE}"
          echo "${searx_results}" | while IFS='|' read -r title url content; do
            {
              echo "    📄 ${title}"
              echo "       ${content}"
              echo "       🔗 ${url}"
            } >>"${LOG_FILE}"
          done
        fi
      fi
    fi

    # If no web results, provide helpful message
    if [[ -z ${instant_answer} ]] && [[ -z ${searx_results} ]]; then
      all_results="🌐 Web search completed - no instant results available
    💡 Try more specific search terms or check network connectivity"
    else
      # Build results string for caching
      if [[ -n ${instant_answer} ]]; then
        all_results="${all_results}🌐 Instant Results:
${instant_answer}
"
      fi
      if [[ -n ${searx_results} ]]; then
        all_results="${all_results}🔍 Additional Results:
${searx_results}
"
      fi
    fi

    # Cache the results if we got any
    if [[ -n ${all_results} ]]; then
      cache_result "${query}" "${all_results}"
    fi
  else
    all_results="🌐 curl not available for web search"
  fi

  # Output results to log
  if [[ -n ${all_results} ]]; then
    echo "${all_results}" | while IFS= read -r line; do
      echo "  ${line}" >>"${LOG_FILE}"
    done
  fi
}

trap 'update_status stopped; exit 0' SIGTERM SIGINT

while true; do
  update_status "running"
  echo "[$(date)] ${AGENT_NAME}: Checking for new search queries..." >>"${LOG_FILE}"
  processed_any=false
  for query_file in "${QUERY_DIR}"/*.query; do
    [[ -e ${query_file} ]] || continue
    processed_any=true
    query=$(<"${query_file}")
    echo "[$(date)] ${AGENT_NAME}: Searching for: ${query}" >>"${LOG_FILE}"

    # Perform comprehensive search across multiple sources
    search_codebase "${query}"
    search_documentation "${query}"
    search_web "${query}" 2>/dev/null || echo "[$(date)] ${AGENT_NAME}: Web search not available" >>"${LOG_FILE}"

    rm "${query_file}"
  done
  echo "[$(date)] ${AGENT_NAME}: Search cycle complete." >>"${LOG_FILE}"
  if [[ ${processed_any} == true ]]; then
    SLEEP_INTERVAL=${MIN_INTERVAL}
  else
    SLEEP_INTERVAL=$((SLEEP_INTERVAL + 300))
    if ((SLEEP_INTERVAL > MAX_INTERVAL)); then
      SLEEP_INTERVAL=${MAX_INTERVAL}
    fi
  fi
  echo "[$(date)] ${AGENT_NAME}: Sleeping for ${SLEEP_INTERVAL} seconds." >>"${LOG_FILE}"
  update_status "idle"
  sleep "${SLEEP_INTERVAL}"
done
