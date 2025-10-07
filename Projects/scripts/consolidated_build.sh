#!/bin/bash
set -euo pipefail

JSON_MODE=0
for arg in "$@"; do
  if [[ "$arg" == "--json" ]]; then JSON_MODE=1; fi
  if [[ "$arg" == "--help" ]]; then
    cat <<'USAGE'
Usage: ./consolidated_build.sh [--json]

Environment overrides:
  IOS_OS_VERSION       iOS runtime version for simulator lookups (default: 26.0)
  IOS_DEVICE_NAME      Simulator device name (default: "iPhone 7")
  IOS_DEVICE_ID        Explicit simulator UDID to use (overrides lookup)
  MAC_OS_VERSION       macOS runtime version for mac builds (default: 26.0)
  IOS_SCHEMES          Space-delimited override for iOS schemes
  MAC_SCHEMES          Space-delimited override for macOS schemes
  ENABLE_MAC_PRIMARY   When set to 0, skips proactive mac builds (default: 1)
USAGE
    exit 0
  fi
done

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="${ROOT_DIR}/scripts"
LOG_SUMMARY="${ROOT_DIR}/build_summary.txt"

: >"${LOG_SUMMARY}"
append_summary() {
  printf '%s\n' "$1" | tee -a "${LOG_SUMMARY}" >/dev/null
}

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
fi

record_success() {
  local scheme="$1" label="$2" dest="$3" meta_path="$4" platform="$5"
  local entry
  if [[ -n "${PYTHON_BIN}" && -f "${meta_path}" ]]; then
    entry="$(
      ${PYTHON_BIN} - "$meta_path" "$label" "$dest" "$platform" "$scheme" <<'PY'
import json, sys
meta_path, label, dest, platform, scheme = sys.argv[1:6]
try:
    data = json.load(open(meta_path))
except Exception:
    data = {}
data["scheme"] = scheme
data["label"] = label
data["platform"] = platform
data["destination"] = dest
data["status"] = "success"
print(json.dumps(data))
PY
    )"
  else
    entry=$(printf '{"scheme":"%s","label":"%s","platform":"%s","destination":"%s","status":"success"}' \
      "${scheme}" "${label}" "${platform}" "${dest}")
  fi
  RESULT_JSON_ENTRIES+=("${entry}")
}

record_failure() {
  local scheme="$1" label="$2" dest="$3" platform="$4" reason="$5"
  local entry
  if [[ -n "${PYTHON_BIN}" ]]; then
    entry="$(
      ${PYTHON_BIN} - "$scheme" "$label" "$dest" "$platform" "$reason" <<'PY'
import json, sys
scheme, label, dest, platform, reason = sys.argv[1:6]
print(json.dumps({
    "scheme": scheme,
    "label": label,
    "platform": platform,
    "destination": dest,
    "status": "failure",
    "reason": reason
}))
PY
    )"
  else
    entry=$(printf '{"scheme":"%s","label":"%s","platform":"%s","destination":"%s","status":"failure","reason":"%s"}' \
      "${scheme}" "${label}" "${platform}" "${dest}" "${reason}")
  fi
  RESULT_JSON_ENTRIES+=("${entry}")
}

copy_meta_variant() {
  local meta_path="$1" variant="$2"
  if [[ -f "${meta_path}" ]]; then
    cp "${meta_path}" "${meta_path%/last_success.json}/last_success_${variant}.json" 2>/dev/null || true
  fi
}

IOS_OS_VERSION="${IOS_OS_VERSION:-26.0}"
IOS_DEVICE_NAME="${IOS_DEVICE_NAME:-iPhone 7}"
MAC_OS_VERSION="${MAC_OS_VERSION:-26.0}"
ENABLE_MAC_PRIMARY="${ENABLE_MAC_PRIMARY:-1}"

RESULT_JSON_ENTRIES=()
EXIT_CODE=0

append_summary "Build Summary - $(date)"
append_summary "===================================="

resolve_simulator_id() {
  local os_version="$1"
  local device_name="$2"
  local runtime="com.apple.CoreSimulator.SimRuntime.iOS-${os_version//./-}"
  if [[ -z "${PYTHON_BIN}" ]]; then
    return 1
  fi
  local json_output
  if ! json_output=$(xcrun simctl list devices --json 2>/dev/null); then
    return 1
  fi
  local udid
  udid=$(
    printf '%s' "${json_output}" | ${PYTHON_BIN} - "$runtime" "$device_name" <<'PY'
import json, sys
runtime = sys.argv[1]
device_name = sys.argv[2]
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for device in data.get("devices", {}).get(runtime, []):
    if device.get("name") == device_name and device.get("isAvailable"):
        print(device.get("udid", ""))
        break
PY
  ) || true
  if [[ -n "${udid}" ]]; then
    printf '%s' "${udid}"
    return 0
  fi
  return 1
}

DEFAULT_SIM_ID="43C262CD-FEC5-4CEB-8632-48B9AB5CF5EF"
SELECTED_SIM_ID="${IOS_DEVICE_ID:-}"

if [[ -z "${SELECTED_SIM_ID}" ]]; then
  if SELECTED_SIM_ID=$(resolve_simulator_id "${IOS_OS_VERSION}" "${IOS_DEVICE_NAME}"); then
    :
  elif xcrun simctl list devices | grep -q "${DEFAULT_SIM_ID}" 2>/dev/null; then
    SELECTED_SIM_ID="${DEFAULT_SIM_ID}"
  else
    SELECTED_SIM_ID=""
  fi
fi

IOS_DEST="platform=iOS Simulator,OS=${IOS_OS_VERSION},name=${IOS_DEVICE_NAME}"
if [[ -n "${SELECTED_SIM_ID}" ]]; then
  IOS_DEVICE_ID="${SELECTED_SIM_ID}"
  IOS_DEST="platform=iOS Simulator,id=${IOS_DEVICE_ID}"
fi

if [[ -n "${IOS_DEVICE_ID:-}" ]]; then
  if ! "${SCRIPTS_DIR}/prewarm_simulator.sh" "${IOS_DEVICE_ID}"; then
    append_summary "[warn] Simulator prewarm reported an issue"
  fi
else
  append_summary "[info] No simulator UDID resolved; skipping prewarm"
fi

DEFAULT_IOS_SCHEMES=("PlannerApp" "HabitQuest" "AvoidObstaclesGame")
DEFAULT_MAC_SCHEMES=("CodingReviewer" "PlannerApp" "MomentumFinance")

if [[ -n "${IOS_SCHEMES:-}" ]]; then
  read -r -a IOS_SCHEME_LIST <<<"${IOS_SCHEMES}"
else
  IOS_SCHEME_LIST=("${DEFAULT_IOS_SCHEMES[@]}")
fi

if [[ -n "${MAC_SCHEMES:-}" ]]; then
  read -r -a MAC_SCHEME_LIST <<<"${MAC_SCHEMES}"
else
  MAC_SCHEME_LIST=("${DEFAULT_MAC_SCHEMES[@]}")
fi

run_build() {
  local scheme="$1" label="$2" dest="$3" platform="$4" log_suffix="$5" meta_variant="$6"
  local fallback_dest="${7:-}"
  local fallback_label="${8:-${label} (fallback)}"
  local fallback_variant="${9:-${meta_variant}}"
  local project_dir="${ROOT_DIR}/${scheme}"

  append_summary "\n=== Building ${label} (${dest}) ==="
  if LOG_SUFFIX="${log_suffix}" DISABLE_INTERNAL_FALLBACK=1 "${SCRIPTS_DIR}/build_with_retry.sh" "${project_dir}" "${scheme}" "${dest}"; then
    append_summary "[OK] ${label}"
    local meta_path="${project_dir}/build_meta/last_success.json"
    if [[ -n "${meta_variant}" ]]; then
      copy_meta_variant "${meta_path}" "${meta_variant}"
    fi
    record_success "${scheme}" "${label}" "${dest}" "${meta_path}" "${platform}"
    return 0
  else
    local status=$?
    if [[ -n "${fallback_dest}" ]]; then
      append_summary "[warn] ${label} failed (exit ${status}); retrying with fallback destination ${fallback_dest}"
      if LOG_SUFFIX="${log_suffix}_fallback" DISABLE_INTERNAL_FALLBACK=1 "${SCRIPTS_DIR}/build_with_retry.sh" "${project_dir}" "${scheme}" "${fallback_dest}"; then
        append_summary "[OK] ${fallback_label}"
        local meta_path="${project_dir}/build_meta/last_success.json"
        if [[ -n "${fallback_variant}" ]]; then
          copy_meta_variant "${meta_path}" "${fallback_variant}"
        fi
        record_success "${scheme}" "${fallback_label}" "${fallback_dest}" "${meta_path}" "${platform}"
        return 0
      else
        local fallback_status=$?
        append_summary "[FAIL] ${fallback_label} (exit ${fallback_status})"
        EXIT_CODE=1
        record_failure "${scheme}" "${fallback_label}" "${fallback_dest}" "${platform}" "exit ${fallback_status}"
        return ${fallback_status}
      fi
    fi

    append_summary "[FAIL] ${label} (exit ${status})"
    EXIT_CODE=1
    record_failure "${scheme}" "${label}" "${dest}" "${platform}" "exit ${status}"
    return ${status}
  fi
}

for scheme in "${IOS_SCHEME_LIST[@]}"; do
  run_build "${scheme}" "${scheme} iOS" "${IOS_DEST}" "iOS" "ios" "ios" || true
done

if [[ "${ENABLE_MAC_PRIMARY}" == "1" ]]; then
  MAC_DEST_PLATFORM="platform=macOS"
  mac_primary_dest="${MAC_DEST_PLATFORM}"
  mac_label_suffix=""
  if [[ -n "${MAC_OS_VERSION}" ]]; then
    mac_primary_dest="platform=macOS,OS=${MAC_OS_VERSION}"
    mac_label_suffix=" (OS ${MAC_OS_VERSION})"
  fi
  for scheme in "${MAC_SCHEME_LIST[@]}"; do
    if [[ -n "${MAC_OS_VERSION}" ]]; then
      run_build "${scheme}" "${scheme} macOS${mac_label_suffix}" "${mac_primary_dest}" "macOS" "mac" "mac" "${MAC_DEST_PLATFORM}" "${scheme} macOS" || true
    else
      run_build "${scheme}" "${scheme} macOS" "${mac_primary_dest}" "macOS" "mac" "mac" || true
    fi
  done
else
  append_summary "\n[info] Skipping macOS primary builds (ENABLE_MAC_PRIMARY=0)"
fi

append_summary "\nDetailed logs stored per project under build_logs/."
append_summary "Final result: $([[ ${EXIT_CODE} -eq 0 ]] && echo SUCCESS || echo FAILURE)"

if [[ ${JSON_MODE} -eq 1 ]]; then
  overall=$([[ ${EXIT_CODE} -eq 0 ]] && echo SUCCESS || echo FAILURE)
  printf '{"generated_at":%s,"result":"%s","schemes":[' "$(date +%s)" "${overall}"
  first=1
  for entry in "${RESULT_JSON_ENTRIES[@]}"; do
    if [[ $first -eq 0 ]]; then
      printf ','
    fi
    first=0
    printf '%s' "${entry}"
  done
  printf ']}\n'
fi

exit ${EXIT_CODE}
