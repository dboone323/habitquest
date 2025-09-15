#!/bin/bash
# Quantum Workspace Master Startup Script
# Ensures all agents, MCP, and automation components are running properly

WORKSPACE_DIR="/Users/danielstevens/Desktop/Quantum-workspace"
TOOLS_DIR="$WORKSPACE_DIR/Tools"
AUTOMATION_DIR="$TOOLS_DIR/Automation"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[STARTUP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a process is running
check_process() {
    local process_name="$1"
    local port="$2"

    if [[ -n "$port" ]]; then
        if lsof -i :"$port" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        if pgrep -f "$process_name" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

# Function to start MCP server
start_mcp_server() {
    log_info "Starting MCP Server..."

    if check_process "mcp_server.py" "5005"; then
        log_warning "MCP Server already running on port 5005"
        return 0
    fi

    cd "$AUTOMATION_DIR" || return 1
    nohup python3 mcp_server.py > mcp_server.log 2>&1 &
    sleep 3

    if check_process "mcp_server.py" "5005"; then
        log_success "MCP Server started successfully on port 5005"
        return 0
    else
        log_error "Failed to start MCP Server"
        return 1
    fi
}

# Function to start MCP dashboard
start_mcp_dashboard() {
    log_info "Starting MCP Dashboard..."

    if check_process "mcp_dashboard_flask.py" "8080"; then
        log_warning "MCP Dashboard already running on port 8080"
        return 0
    fi

    cd "$AUTOMATION_DIR" || return 1
    nohup python3 mcp_dashboard_flask.py > mcp_dashboard.log 2>&1 &
    sleep 3

    if check_process "mcp_dashboard_flask.py" "8080"; then
        log_success "MCP Dashboard started successfully on port 8080"
        return 0
    else
        log_error "Failed to start MCP Dashboard"
        return 1
    fi
}

# Function to start web dashboard
start_web_dashboard() {
    log_info "Starting Web Dashboard..."

    if check_process "mcp_web_dashboard.py" "8081"; then
        log_warning "Web Dashboard already running on port 8081"
        return 0
    fi

    cd "$AUTOMATION_DIR" || return 1
    MCP_WEB_PORT=8081 nohup python3 mcp_web_dashboard.py > web_dashboard.log 2>&1 &
    sleep 3

    if check_process "mcp_web_dashboard.py" "8081"; then
        log_success "Web Dashboard started successfully on port 8081"
        return 0
    else
        log_error "Failed to start Web Dashboard"
        return 1
    fi
}

# Function to start agent supervisor
start_agent_supervisor() {
    log_info "Starting Agent Supervisor..."

    # Kill any existing agent processes
    pkill -f "agent_supervisor.sh" 2>/dev/null || true
    pkill -f "agent_build.sh" 2>/dev/null || true
    pkill -f "agent_debug.sh" 2>/dev/null || true
    pkill -f "agent_codegen.sh" 2>/dev/null || true

    # Start agent supervisor
    cd "${AUTOMATION_DIR}/agents" || return 1
    nohup bash agent_supervisor.sh >/dev/null 2>&1 &
    local supervisor_pid=$!
    echo $supervisor_pid > "${AUTOMATION_DIR}/agents/agent_supervisor.pid"
    cd - >/dev/null || return 1

    # Wait a moment for agents to start
    sleep 3

    # Check if agents are running
    local agent_count
    agent_count=$(pgrep -f "agent_(build|debug|codegen)" | wc -l)

    if [[ $agent_count -ge 3 ]]; then
        log_success "Agent Supervisor started successfully ($agent_count agents running)"
        return 0
    else
        log_error "Failed to start Agent Supervisor (only $agent_count agents running)"
        return 1
    fi
}

# Function to test MCP connectivity
test_mcp_connectivity() {
    log_info "Testing MCP connectivity..."

    local response
    response=$(curl -s http://127.0.0.1:5005/status 2>/dev/null)
    if curl -s http://127.0.0.1:5005/status >/dev/null 2>&1 && [[ "$response" == *"\"ok\": true"* ]]; then
        log_success "MCP Server connectivity test passed"
        return 0
    else
        log_error "MCP Server connectivity test failed"
        return 1
    fi
}

# Function to test dashboard connectivity
test_dashboard_connectivity() {
    log_info "Testing Dashboard connectivity..."

    local mcp_dashboard
    mcp_dashboard=$(curl -s http://127.0.0.1:8080/ 2>/dev/null | grep -c "MCP Dashboard")

    local web_dashboard
    web_dashboard=$(curl -s http://127.0.0.1:8081/ 2>/dev/null | grep -c "html")

    if [[ $mcp_dashboard -gt 0 ]]; then
        log_success "MCP Dashboard connectivity test passed"
    else
        log_warning "MCP Dashboard connectivity test failed"
    fi

    if [[ $web_dashboard -gt 0 ]]; then
        log_success "Web Dashboard connectivity test passed"
    else
        log_warning "Web Dashboard connectivity test failed"
    fi
}

# Function to run full system test
run_full_test() {
    log_info "Running full system test..."

    # Test MCP commands
    local test_result
    test_result=$(curl -s -X POST http://127.0.0.1:5005/run \
        -H "Content-Type: application/json" \
        -d '{"agent": "test", "command": "status", "project": "", "execute": true}' 2>/dev/null)

    if curl -s -X POST http://127.0.0.1:5005/run \
        -H "Content-Type: application/json" \
        -d '{"agent": "test", "command": "status", "project": "", "execute": true}' >/dev/null 2>&1 && [[ "$test_result" == *"\"ok\": true"* ]]; then
        log_success "Full system test passed"
        return 0
    else
        log_error "Full system test failed"
        return 1
    fi
}

# Function to show status
show_status() {
    echo ""
    log_info "=== QUANTUM WORKSPACE STATUS ==="
    echo ""

    # MCP Server
    if check_process "mcp_server.py" "5005"; then
        echo -e "✅ MCP Server:        ${GREEN}Running${NC} (Port 5005)"
    else
        echo -e "❌ MCP Server:        ${RED}Not Running${NC}"
    fi

    # MCP Dashboard
    if check_process "mcp_dashboard_flask.py" "8080"; then
        echo -e "✅ MCP Dashboard:     ${GREEN}Running${NC} (Port 8080)"
    else
        echo -e "❌ MCP Dashboard:     ${RED}Not Running${NC}"
    fi

    # Web Dashboard
    if check_process "mcp_web_dashboard.py" "8081"; then
        echo -e "✅ Web Dashboard:     ${GREEN}Running${NC} (Port 8081)"
    else
        echo -e "❌ Web Dashboard:     ${RED}Not Running${NC}"
    fi

    # Agent count
    local agent_count
    agent_count=$(pgrep -f "agent_(build|debug|codegen)" | wc -l)
    if [[ $agent_count -ge 3 ]]; then
        echo -e "✅ Agents:            ${GREEN}Running${NC} ($agent_count active)"
    else
        echo -e "❌ Agents:            ${RED}Not Running${NC} (only $agent_count active)"
    fi

    echo ""
    log_info "Access URLs:"
    echo "  MCP Dashboard:     http://127.0.0.1:8080"
    echo "  Web Dashboard:     http://127.0.0.1:8081"
    echo "  MCP API:           http://127.0.0.1:5005"
    echo ""
}

# Main execution
main() {
    log_info "Starting Quantum Workspace Master Startup..."

    local errors=0

    # Start components
    start_mcp_server || ((errors++))
    start_mcp_dashboard || ((errors++))
    start_web_dashboard || ((errors++))
    start_agent_supervisor || ((errors++))

    # Test connectivity
    test_mcp_connectivity || ((errors++))
    test_dashboard_connectivity

    # Run full test
    run_full_test || ((errors++))

    # Show final status
    show_status

    if [[ $errors -eq 0 ]]; then
        log_success "Quantum Workspace startup completed successfully!"
        echo ""
        log_info "🎉 All systems are GO! Your AI agents, MCP, and automation are working together."
        echo ""
        log_info "Next steps:"
        echo "  1. Open http://127.0.0.1:8080 for MCP Dashboard"
        echo "  2. Open http://127.0.0.1:8081 for Web Dashboard"
        echo "  3. Run: ./Tools/Automation/master_automation.sh status"
        echo "  4. Test agents: curl http://127.0.0.1:5005/status"
    else
        log_error "Quantum Workspace startup completed with $errors errors."
        echo ""
        log_info "Troubleshooting:"
        echo "  1. Check logs in $AUTOMATION_DIR/*.log"
        echo "  2. Run: ./Tools/Automation/master_automation.sh status"
        echo "  3. Restart with: bash $0"
    fi

    return $errors
}

# Run main function
main "$@"