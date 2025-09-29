#!/usr/bin/env python3
"""
MCP (Model Context Protocol) Server for Agent Communication
Provides REST API endpoints for agent registration, task distribution, and coordination
"""

import json
import logging
import os
import subprocess
import sys
import threading
import time
from typing import Dict, List, Optional

try:
    from flask import Flask, jsonify, request
    from flask_cors import CORS
except ImportError:
    print(
        "Flask and flask-cors required. Install: pip install flask flask-cors",
        file=sys.stderr,
    )
    sys.exit(1)

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuration
WORKSPACE_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
AGENTS_DIR = os.path.dirname(__file__)
TASK_QUEUE_FILE = os.path.join(AGENTS_DIR, "task_queue.json")
AGENT_STATUS_FILE = os.path.join(AGENTS_DIR, "agent_status.json")
COMMUNICATION_DIR = os.path.join(AGENTS_DIR, "communication")

# Global state
agents: Dict[str, Dict] = {}
tasks: List[Dict] = []
completed_tasks: List[Dict] = []
failed_tasks: List[Dict] = []

# Agent capabilities mapping
AGENT_CAPABILITIES = {
    "agent_build.sh": ["build", "test", "compile", "xcode"],
    "agent_debug.sh": ["debug", "fix", "diagnose", "troubleshoot"],
    "agent_codegen.sh": ["generate", "code", "create", "implement"],
    "uiux_agent.sh": ["ui", "ux", "interface", "design", "user_experience"],
    "apple_pro_agent.sh": ["ios", "swift", "apple", "frameworks"],
    "collab_agent.sh": ["coordinate", "plan", "organize", "collaborate"],
    "updater_agent.sh": ["update", "upgrade", "modernize", "enhance"],
    "search_agent.sh": ["search", "find", "locate", "discover"],
    "pull_request_agent.sh": ["pr", "pull_request", "merge", "review"],
    "auto_update_agent.sh": ["auto_update", "enhancement", "best_practices"],
    "knowledge_base_agent.sh": ["knowledge", "learn", "share", "best_practices"],
    "agent_todo.sh": ["todo", "task_creation", "scan", "analysis"],
}

# Priority levels for agents
AGENT_PRIORITIES = {
    "agent_debug.sh": 9,
    "agent_build.sh": 8,
    "pull_request_agent.sh": 7,
    "auto_update_agent.sh": 6,
    "agent_codegen.sh": 5,
    "uiux_agent.sh": 4,
    "apple_pro_agent.sh": 4,
    "collab_agent.sh": 3,
    "updater_agent.sh": 3,
    "search_agent.sh": 2,
    "knowledge_base_agent.sh": 1,
    "agent_todo.sh": 8,
}


class MCPServer:
    def __init__(self):
        self.load_state()
        self.ensure_directories()

    def ensure_directories(self):
        """Ensure all required directories exist"""
        os.makedirs(COMMUNICATION_DIR, exist_ok=True)

    def load_state(self):
        """Load tasks and agent status from files"""
        global tasks, completed_tasks, failed_tasks, agents

        try:
            if os.path.exists(TASK_QUEUE_FILE):
                with open(TASK_QUEUE_FILE, "r") as f:
                    data = json.load(f)
                    tasks = data.get("tasks", [])
                    completed_tasks = data.get("completed", [])
                    failed_tasks = data.get("failed", [])
        except Exception as e:
            logger.error(f"Failed to load task queue: {e}")
            tasks, completed_tasks, failed_tasks = [], [], []

        try:
            if os.path.exists(AGENT_STATUS_FILE):
                with open(AGENT_STATUS_FILE, "r") as f:
                    data = json.load(f)
                    agents = data.get("agents", {})
        except Exception as e:
            logger.error(f"Failed to load agent status: {e}")
            agents = {}

    def save_state(self):
        """Save current state to files"""
        try:
            task_data = {
                "tasks": tasks,
                "completed": completed_tasks,
                "failed": failed_tasks,
            }
            with open(TASK_QUEUE_FILE, "w") as f:
                json.dump(task_data, f, indent=2)

            agent_data = {"agents": agents, "last_update": int(time.time())}
            with open(AGENT_STATUS_FILE, "w") as f:
                json.dump(agent_data, f, indent=2)

        except Exception as e:
            logger.error(f"Failed to save state: {e}")

    def get_best_agent_for_task(self, task_type: str) -> Optional[str]:
        """Select the best agent for a given task type"""
        best_agent = None
        best_score = -1

        for agent_name, capabilities in AGENT_CAPABILITIES.items():
            if not os.path.exists(os.path.join(AGENTS_DIR, agent_name)):
                continue

            score = 0

            # Check if agent has relevant capabilities
            if task_type in capabilities:
                score += 10
            elif any(task_type in cap for cap in capabilities):
                score += 5

            # Add priority score
            score += AGENT_PRIORITIES.get(agent_name, 1)

            # Check agent availability
            agent_status = agents.get(agent_name, {}).get("status", "unknown")
            if agent_status in ["available", "idle", "unknown"]:
                score += 5
            elif agent_status == "busy":
                score -= 3
            elif agent_status == "unresponsive":
                score -= 10

            if score > best_score:
                best_score = score
                best_agent = agent_name

        return best_agent

    def create_task(
        self,
        task_type: str,
        description: str,
        priority: int = 5,
        project: Optional[str] = None,
        file_path: Optional[str] = None,
    ) -> Dict:
        """Create a new task"""
        task_id = f"{int(time.time() * 1000)}_{len(tasks)}"
        assigned_agent = self.get_best_agent_for_task(task_type)

        if not assigned_agent:
            logger.warning(f"No suitable agent found for task type: {task_type}")
            return None

        task = {
            "id": task_id,
            "type": task_type,
            "description": description,
            "priority": priority,
            "assigned_agent": assigned_agent,
            "status": "queued",
            "created": int(time.time()),
            "project": project,
            "file_path": file_path,
            "dependencies": [],
        }

        tasks.append(task)
        self.save_state()

        # Notify assigned agent
        self.notify_agent(assigned_agent, "new_task", task_id)

        logger.info(
            f"Created task {task_id} ({task_type}) assigned to {assigned_agent}"
        )
        return task

    def notify_agent(self, agent_name: str, notification_type: str, task_id: str):
        """Send notification to an agent"""
        notification_file = os.path.join(
            COMMUNICATION_DIR, f"{agent_name}_notification.txt"
        )
        timestamp = int(time.time())

        try:
            with open(notification_file, "a") as f:
                f.write(f"{timestamp}|{notification_type}|{task_id}\n")
        except Exception as e:
            logger.error(f"Failed to notify agent {agent_name}: {e}")

    def ensure_agent_running(self, agent_name: str) -> bool:
        """Ensure an agent is running, start if necessary"""
        agent_path = os.path.join(AGENTS_DIR, agent_name)
        pid_file = os.path.join(AGENTS_DIR, f"{agent_name}.pid")

        if not os.path.exists(agent_path):
            logger.error(f"Agent script not found: {agent_path}")
            return False

        # Check if agent is running
        if os.path.exists(pid_file):
            try:
                with open(pid_file, "r") as f:
                    pid = int(f.read().strip())
                # Check if process is still running
                os.kill(pid, 0)  # This will raise an exception if process doesn't exist
                return True
            except (OSError, ValueError):
                # Process not running or invalid PID
                pass

        # Start the agent
        try:
            log_file = os.path.join(AGENTS_DIR, f"{agent_name}.log")
            with open(log_file, "a") as f:
                process = subprocess.Popen(
                    ["bash", agent_path],
                    stdout=f,
                    stderr=subprocess.STDOUT,
                    cwd=AGENTS_DIR,
                )

            # Write PID file
            with open(pid_file, "w") as f:
                f.write(str(process.pid))

            logger.info(f"Started agent {agent_name} with PID {process.pid}")
            return True

        except Exception as e:
            logger.error(f"Failed to start agent {agent_name}: {e}")
            return False

    def auto_create_todo_tasks(self):
        """Automatically scan for TODOs and create tasks"""
        todo_file = os.path.join(WORKSPACE_ROOT, "Projects", "todo-tree-output.json")

        if not os.path.exists(todo_file):
            # Generate TODO file by scanning workspace
            try:
                result = subprocess.run(
                    [
                        "find",
                        WORKSPACE_ROOT,
                        "-name",
                        "*.swift",
                        "-o",
                        "-name",
                        "*.py",
                        "-o",
                        "-name",
                        "*.sh",
                        "-o",
                        "-name",
                        "*.js",
                        "-o",
                        "-name",
                        "*.ts",
                    ],
                    capture_output=True,
                    text=True,
                )

                todos = []
                for file_path in result.stdout.strip().split("\n"):
                    if not file_path:
                        continue

                    try:
                        with open(file_path, "r") as f:
                            for line_num, line in enumerate(f, 1):
                                if "TODO" in line or "FIXME" in line or "HACK" in line:
                                    todos.append(
                                        {
                                            "file": os.path.relpath(
                                                file_path, WORKSPACE_ROOT
                                            ),
                                            "line": line_num,
                                            "text": line.strip(),
                                        }
                                    )
                    except Exception:
                        continue

                # Save TODO file
                with open(todo_file, "w") as f:
                    json.dump(todos, f, indent=2)

                logger.info(f"Generated TODO file with {len(todos)} items")

            except Exception as e:
                logger.error(f"Failed to generate TODO file: {e}")
                return

        # Load TODOs and create tasks
        try:
            with open(todo_file, "r") as f:
                todos = json.load(f)

            for todo in todos:
                file_path = todo.get("file", "")
                text = todo.get("text", "").lower()

                # Avoid creating duplicate tasks
                existing_task = next(
                    (
                        t
                        for t in tasks
                        if todo.get("text", "") in t.get("description", "")
                    ),
                    None,
                )
                if existing_task:
                    continue

                # Determine task type
                task_type = "generate"
                if any(word in text for word in ["debug", "fix", "error", "bug"]):
                    task_type = "debug"
                elif any(word in text for word in ["build", "compile", "test"]):
                    task_type = "build"
                elif any(word in text for word in ["ui", "interface", "design"]):
                    task_type = "ui"

                # Determine project
                project = None
                if file_path.startswith("Projects/"):
                    project_path = file_path.split("/")[1:2]
                    if project_path:
                        project = project_path[0]

                self.create_task(
                    task_type=task_type,
                    description=f"TODO: {todo.get('text', '')}",
                    priority=7,
                    project=project,
                    file_path=file_path,
                )

        except Exception as e:
            logger.error(f"Failed to process TODOs: {e}")

    def monitor_agents(self):
        """Monitor agent health and restart if needed"""
        current_time = int(time.time())

        for agent_name in AGENT_CAPABILITIES.keys():
            if agent_name not in agents:
                agents[agent_name] = {
                    "status": "unknown",
                    "last_seen": 0,
                    "tasks_completed": 0,
                }

            agent_info = agents[agent_name]
            last_seen = int(agent_info.get("last_seen", 0))

            # If agent hasn't been seen for more than 20 minutes, mark as unresponsive
            if current_time - last_seen > 1200:
                if agent_info.get("status") != "unresponsive":
                    logger.warning(f"Agent {agent_name} is unresponsive")
                    agent_info["status"] = "unresponsive"

                    # Try to restart essential agents
                    if agent_name in [
                        "agent_build.sh",
                        "agent_debug.sh",
                        "agent_codegen.sh",
                        "agent_todo.sh",
                    ]:
                        self.ensure_agent_running(agent_name)

        self.save_state()

    def start_background_tasks(self):
        """Start background monitoring and task creation"""

        def background_worker():
            while True:
                try:
                    # Monitor agents every 2 minutes
                    self.monitor_agents()

                    # Auto-create TODO tasks every 5 minutes
                    if (
                        int(time.time()) % 300 < 60
                    ):  # Every 5 minutes with 1-minute window
                        self.auto_create_todo_tasks()

                    time.sleep(60)  # Check every minute

                except Exception as e:
                    logger.error(f"Background worker error: {e}")
                    time.sleep(30)

        thread = threading.Thread(target=background_worker, daemon=True)
        thread.start()
        logger.info("Started background monitoring thread")


# Initialize server
server = MCPServer()

# REST API Endpoints


@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint"""
    return jsonify({"ok": True, "agents": len(agents), "tasks": len(tasks)})


@app.route("/register", methods=["POST"])
def register_agent():
    """Register an agent with the server"""
    data = request.get_json()
    agent_name = data.get("agent")
    capabilities = data.get("capabilities", [])

    if not agent_name:
        return jsonify({"error": "Agent name required"}), 400

    agents[agent_name] = {
        "status": "available",
        "last_seen": int(time.time()),
        "capabilities": capabilities,
        "tasks_completed": agents.get(agent_name, {}).get("tasks_completed", 0),
    }

    server.save_state()
    logger.info(f"Registered agent: {agent_name} with capabilities: {capabilities}")

    return jsonify(
        {"ok": True, "message": f"Agent {agent_name} registered successfully"}
    )


@app.route("/heartbeat", methods=["POST"])
def heartbeat():
    """Receive heartbeat from agent"""
    data = request.get_json()
    agent_name = data.get("agent")

    if not agent_name:
        return jsonify({"error": "Agent name required"}), 400

    if agent_name not in agents:
        agents[agent_name] = {"status": "available", "tasks_completed": 0}

    agents[agent_name]["last_seen"] = int(time.time())
    if agents[agent_name].get("status") == "unresponsive":
        agents[agent_name]["status"] = "available"

    server.save_state()
    return jsonify({"ok": True})


@app.route("/status", methods=["GET"])
def get_status():
    """Get current system status"""
    return jsonify(
        {
            "agents": agents,
            "tasks": tasks,
            "completed": completed_tasks[-10:],  # Last 10 completed
            "failed": failed_tasks[-10:],  # Last 10 failed
            "stats": {
                "total_agents": len(agents),
                "active_agents": len(
                    [
                        a
                        for a in agents.values()
                        if a.get("status") in ["available", "busy"]
                    ]
                ),
                "queued_tasks": len(tasks),
                "completed_tasks": len(completed_tasks),
                "failed_tasks": len(failed_tasks),
            },
        }
    )


@app.route("/create_task", methods=["POST"])
def create_task():
    """Create a new task"""
    data = request.get_json()

    task_type = data.get("type", "generate")
    description = data.get("description", "")
    priority = data.get("priority", 5)
    project = data.get("project")
    file_path = data.get("file_path")

    if not description:
        return jsonify({"error": "Task description required"}), 400

    task = server.create_task(task_type, description, priority, project, file_path)

    if task:
        return jsonify({"ok": True, "task": task})
    else:
        return jsonify({"error": "No suitable agent found for task"}), 400


@app.route("/execute_task", methods=["POST"])
def execute_task():
    """Mark a task for execution"""
    data = request.get_json()
    task_id = data.get("task_id")

    if not task_id:
        return jsonify({"error": "Task ID required"}), 400

    # Find the task
    task = next((t for t in tasks if t["id"] == task_id), None)
    if not task:
        return jsonify({"error": "Task not found"}), 404

    # Update task status
    task["status"] = "executing"
    task["started"] = int(time.time())

    # Update agent status
    assigned_agent = task["assigned_agent"]
    if assigned_agent in agents:
        agents[assigned_agent]["status"] = "busy"

    server.save_state()

    return jsonify({"ok": True, "message": f"Task {task_id} marked for execution"})


@app.route("/complete_task", methods=["POST"])
def complete_task():
    """Mark a task as completed"""
    data = request.get_json()
    task_id = data.get("task_id")
    success = data.get("success", True)
    result = data.get("result", "")

    if not task_id:
        return jsonify({"error": "Task ID required"}), 400

    # Find and remove task from active tasks
    task = None
    for i, t in enumerate(tasks):
        if t["id"] == task_id:
            task = tasks.pop(i)
            break

    if not task:
        return jsonify({"error": "Task not found"}), 404

    # Add completion info
    task["completed"] = int(time.time())
    task["success"] = success
    task["result"] = result
    task["status"] = "completed"

    # Move to appropriate list
    if success:
        completed_tasks.append(task)
    else:
        failed_tasks.append(task)

    # Update agent status and stats
    assigned_agent = task["assigned_agent"]
    if assigned_agent in agents:
        agents[assigned_agent]["status"] = "available"
        agents[assigned_agent]["tasks_completed"] = (
            agents[assigned_agent].get("tasks_completed", 0) + 1
        )

    server.save_state()

    return jsonify({"ok": True, "message": f"Task {task_id} completed"})


@app.route("/run", methods=["POST"])
def run_command():
    """Execute a command through an agent"""
    data = request.get_json()

    agent = data.get("agent", "codegen")
    command = data.get("command", "implement-todo")
    project = data.get("project", "")
    file_path = data.get("file", "")
    todo_text = data.get("todo", "")
    execute = data.get("execute", True)

    # Create task description
    description = f"{command}: {todo_text}" if todo_text else command
    if project:
        description += f" in {project}"
    if file_path:
        description += f" ({file_path})"

    # Map agent to task type
    agent_to_task_type = {
        "build": "build",
        "debug": "debug",
        "codegen": "generate",
        "uiux": "ui",
    }

    task_type = agent_to_task_type.get(agent, "generate")

    # Create and optionally execute task
    task = server.create_task(task_type, description, 7, project, file_path)

    if task and execute:
        # Mark for immediate execution
        task["status"] = "executing"
        task["started"] = int(time.time())

        assigned_agent = task["assigned_agent"]
        server.ensure_agent_running(assigned_agent)

        if assigned_agent in agents:
            agents[assigned_agent]["status"] = "busy"

        server.save_state()

    return jsonify({"ok": True, "task": task})


if __name__ == "__main__":
    # Start background monitoring
    server.start_background_tasks()

    # Start the server
    logger.info("Starting MCP Server on http://127.0.0.1:5005")
    app.run(host="127.0.0.1", port=5005, debug=False)
