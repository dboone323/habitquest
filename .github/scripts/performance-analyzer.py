#!/usr/bin/env python3
"""
Performance Analysis Script for Phase 3
Monitors and analyzes code performance trends
"""

import json
import os
from datetime import datetime

def analyze_performance():
    """Analyze performance benchmark results"""
    if not os.path.exists('benchmark.json'):
        print("No benchmark results found")
        return

    with open('benchmark.json', 'r') as f:
        data = json.load(f)

    print("📊 Performance Analysis Results:")
    print(f"Timestamp: {datetime.now().isoformat()}")

    for benchmark in data.get('benchmarks', []):
        name = benchmark.get('name', 'Unknown')
        time = benchmark.get('stats', {}).get('mean', 0)
        print(".4f")

    # Create performance report
    report = {
        'timestamp': datetime.now().isoformat(),
        'benchmarks': data.get('benchmarks', []),
        'summary': 'Performance monitoring completed'
    }

    with open('performance-report.json', 'w') as f:
        json.dump(report, f, indent=2)

    print("✅ Performance analysis completed!")

if __name__ == "__main__":
    analyze_performance()
