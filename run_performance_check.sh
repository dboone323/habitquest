#!/bin/bash
# Quick performance check script

echo "=== PERFORMANCE ANALYSIS RESULTS ==="
echo "Running analysis across all projects..."
echo ""

# Check for force casts
echo "🔍 FORCE CASTS (as!):"
find Projects -name "*.swift" -exec grep -l "as!" {} \; | while read file; do
    count=$(grep -c "as!" "${file}")
    echo "  ${file}: ${count} force casts"
done
echo ""

# Check for string concatenation
echo "🔗 STRING CONCATENATION (+=):"
find Projects -name "*.swift" -exec grep -l "+=" {} \; | while read file; do
    count=$(grep -c "+=" "${file}")
    echo "  ${file}: ${count} concatenations"
done
echo ""

# Check for nested loops
echo "🔄 NESTED LOOPS:"
find Projects -name "*.swift" -exec sh -c 'count=$(grep -c "for.*in" "$1"); if [ "$count" -gt 2 ]; then echo "  $1: $count loops"; fi' _ {} \;
echo ""

# Check for async functions
echo "⚡ ASYNC FUNCTIONS:"
find Projects -name "*.swift" -exec grep -l "async func" {} \; | wc -l | xargs echo "  Total files with async functions:"
echo ""

# Check for await calls
echo "⏳ AWAIT CALLS:"
find Projects -name "*.swift" -exec grep -l "await" {} \; | wc -l | xargs echo "  Total files with await calls:"
echo ""

echo "=== ANALYSIS COMPLETE ==="
