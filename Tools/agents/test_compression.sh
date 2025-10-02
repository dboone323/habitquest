#!/bin/bash

# Test script for compression functions
source "$(dirname "$0")/task_orchestrator.sh"

# Test compression functions
echo "Testing compression functions..."

test_desc="This is a very long task description that should be compressed because it exceeds the maximum length limit for task descriptions in the system. This description is intentionally made very long to test the compression functionality and ensure that it works correctly with large amounts of text data."

echo "Original description length: ${#test_desc} characters"
echo "Original: ${test_desc}"
echo ""

# Test compression
echo "Testing compression..."
compressed=$(compress_task_description "${test_desc}")
echo "Compressed result: ${compressed}"
echo ""

# Test decompression
echo "Testing decompression..."
decompressed=$(decompress_task_description "${compressed}")
echo "Decompressed: ${decompressed}"
echo ""

# Verify round-trip
if [[ "${test_desc}" == "${decompressed}" ]]; then
  echo "✅ SUCCESS: Round-trip compression/decompression works correctly!"
else
  echo "❌ FAILURE: Round-trip compression/decompression failed!"
  echo "Original != Decompressed"
fi

echo ""
echo "Compression test completed."
