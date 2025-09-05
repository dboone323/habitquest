#!/usr/bin/env python3

import re
import sys


def remove_phantom_files(project_file):
    """Remove references to phantom Swift files from Xcode project"""

    phantom_files = [
        "FinancialInsightModels.swift",
        "SearchAndFilterSection.swift",
        "ThemeEnums.swift",
        "ColorDefinitions.swift",
    ]

    with open(project_file, "r") as f:
        content = f.read()

    original_content = content

    # Track removals
    removals = []

    for phantom_file in phantom_files:
        # Find and remove file references
        # Pattern: 		ABC123DEF456 /* filename */ = {isa = PBXFileReference; ...};
        file_ref_pattern = (
            rf"\t\t[A-F0-9]{{24}} /\* {re.escape(phantom_file)} \*/ = \{{[^}}]+\}};\n"
        )
        matches = re.findall(file_ref_pattern, content)
        if matches:
            content = re.sub(file_ref_pattern, "", content)
            removals.append(f"Removed file reference for {phantom_file}")

        # Find and remove build file references
        # Pattern: 		ABC123DEF456 /* filename in Sources */ = {isa = PBXBuildFile; fileRef = XYZ789; };
        build_file_pattern = rf"\t\t[A-F0-9]{{24}} /\* {re.escape(phantom_file)} in Sources \*/ = \{{[^}}]+\}};\n"
        matches = re.findall(build_file_pattern, content)
        if matches:
            content = re.sub(build_file_pattern, "", content)
            removals.append(f"Removed build file reference for {phantom_file}")

        # Find and remove from sources build phase
        # Pattern: 				ABC123DEF456 /* filename in Sources */,
        sources_pattern = (
            rf"\t\t\t\t[A-F0-9]{{24}} /\* {re.escape(phantom_file)} in Sources \*/,\n"
        )
        matches = re.findall(sources_pattern, content)
        if matches:
            content = re.sub(sources_pattern, "", content)
            removals.append(f"Removed from sources build phase: {phantom_file}")

    if content != original_content:
        with open(project_file, "w") as f:
            f.write(content)

        print("Successfully removed phantom file references:")
        for removal in removals:
            print(f"  - {removal}")
        return True
    else:
        print("No phantom file references found to remove")
        return False


if __name__ == "__main__":
    project_file = "MomentumFinance.xcodeproj/project.pbxproj"
    if remove_phantom_files(project_file):
        print(f"\nProject file updated: {project_file}")
    else:
        print(f"\nNo changes needed to: {project_file}")
