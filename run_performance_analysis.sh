#!/bin/bash
# Direct performance analysis runner

LOG_FILE="/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/performance_agent.log"

echo "[$(date)] Direct performance analysis: Starting..." >>"${LOG_FILE}"

# Performance analysis function (copied from performance_agent.sh)
run_performance_analysis() {
	local task_desc="$1"
	echo "[$(date)] Direct performance analysis: Running performance analysis for: ${task_desc}" >>"${LOG_FILE}"

	# Extract project name from task description
	local projects=("CodingReviewer" "MomentumFinance" "HabitQuest" "PlannerApp" "AvoidObstaclesGame")

	for project in "${projects[@]}"; do
		if [[ -d "/Users/danielstevens/Desktop/Quantum-workspace/Projects/${project}" ]]; then
			echo "[$(date)] Direct performance analysis: Analyzing performance in ${project}..." >>"${LOG_FILE}"
			cd "/Users/danielstevens/Desktop/Quantum-workspace/Projects/${project}" || continue

			# Performance metrics
			echo "[$(date)] Direct performance analysis: Calculating performance metrics for ${project}..." >>"${LOG_FILE}"

			# Count Swift files
			local swift_files=$(find . -name "*.swift" | wc -l)
			echo "[$(date)] Direct performance analysis: Total Swift files: ${swift_files}" >>"${LOG_FILE}"

			# Analyze performance issues
			echo "[$(date)] Direct performance analysis: Analyzing performance bottlenecks..." >>"${LOG_FILE}"

			# Check for performance anti-patterns
			local force_casts=$(find . -name "*.swift" -exec grep -l "as!" {} \; | wc -l)
			local array_operations=$(find . -name "*.swift" -exec grep -l "append\|insert\|remove" {} \; | wc -l)
			local string_concat=$(find . -name "*.swift" -exec grep -l "+=" {} \; | wc -l)
			local nested_loops=$(find . -name "*.swift" -exec grep -A 5 -B 5 "for.*in" {} \; | grep -c "for.*in")
			local large_objects=$(find . -name "*.swift" -exec grep -l "class.*{" {} \; | xargs grep -l "var.*:.*Array\|var.*:.*Dictionary" | wc -l)

			echo "[$(date)] Direct performance analysis: Force casts found in ${force_casts} files" >>"${LOG_FILE}"
			echo "[$(date)] Direct performance analysis: Array operations found in ${array_operations} files" >>"${LOG_FILE}"
			echo "[$(date)] Direct performance analysis: String concatenation found in ${string_concat} files" >>"${LOG_FILE}"
			echo "[$(date)] Direct performance analysis: Nested loops found in ${nested_loops} files" >>"${LOG_FILE}"
			echo "[$(date)] Direct performance analysis: Large objects found in ${large_objects} files" >>"${LOG_FILE}"

			# Check for memory management issues
			local retain_cycles=$(find . -name "*.swift" -exec grep -l "\[weak self\]\|\[unowned self\]" {} \; | wc -l)
			local strong_refs=$(find . -name "*.swift" -exec grep -l "self\." {} \; | wc -l)
			local memory_issues=$((strong_refs - retain_cycles))

			echo "[$(date)] Direct performance analysis: Potential retain cycles: ${memory_issues}" >>"${LOG_FILE}"

			# Check for async/await usage
			local async_funcs=$(find . -name "*.swift" -exec grep -l "async func" {} \; | wc -l)
			local await_calls=$(find . -name "*.swift" -exec grep -l "await" {} \; | wc -l)

			echo "[$(date)] Direct performance analysis: Async functions: ${async_funcs}" >>"${LOG_FILE}"
			echo "[$(date)] Direct performance analysis: Await calls: ${await_calls}" >>"${LOG_FILE}"

			# Calculate performance score (simple heuristic)
			local perf_score=$((100 - (force_casts * 5) - (string_concat * 3) - (nested_loops * 2) - (memory_issues * 4)))
			if [[ ${perf_score} -lt 0 ]]; then
				perf_score=0
			fi

			echo "[$(date)] Direct performance analysis: Performance score for ${project}: ${perf_score}%" >>"${LOG_FILE}"

			# Generate performance recommendations
			echo "[$(date)] Direct performance analysis: Generating performance recommendations..." >>"${LOG_FILE}"

			if [[ ${force_casts} -gt 0 ]]; then
				echo "[$(date)] Direct performance analysis: Recommendation: Replace force casts with safe optional casting" >>"${LOG_FILE}"
			fi

			if [[ ${string_concat} -gt 0 ]]; then
				echo "[$(date)] Direct performance analysis: Recommendation: Use StringBuilder or array joining for string concatenation" >>"${LOG_FILE}"
			fi

			if [[ ${nested_loops} -gt 0 ]]; then
				echo "[$(date)] Direct performance analysis: Recommendation: Review nested loops for optimization opportunities" >>"${LOG_FILE}"
			fi

			if [[ ${memory_issues} -gt 0 ]]; then
				echo "[$(date)] Direct performance analysis: Recommendation: Use weak/unowned references to prevent retain cycles" >>"${LOG_FILE}"
			fi

			if [[ ${async_funcs} -eq 0 ]]; then
				echo "[$(date)] Direct performance analysis: Recommendation: Consider using async/await for I/O operations" >>"${LOG_FILE}"
			fi

			if [[ ${array_operations} -gt 0 ]]; then
				echo "[$(date)] Direct performance analysis: Recommendation: Review array operations for potential optimizations" >>"${LOG_FILE}"
			fi
		fi
	done

	echo "[$(date)] Direct performance analysis: Performance analysis completed" >>"${LOG_FILE}"
}

# Run the analysis
run_performance_analysis "Phase 3 Build Performance Analysis"

echo "[$(date)] Direct performance analysis: Finished" >>"${LOG_FILE}"
