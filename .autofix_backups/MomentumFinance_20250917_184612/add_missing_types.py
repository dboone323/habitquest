#!/usr/bin/env python3

import re
import uuid


def add_file_to_project(project_file, file_path, group_name="MomentumFinance"):
    """Add a Swift file to the Xcode project"""

    with open(project_file, "r") as f:
        content = f.read()

    # Generate UUIDs for the file
    file_ref_uuid = uuid.uuid4().hex[:24].upper()
    build_file_uuid = uuid.uuid4().hex[:24].upper()

    filename = file_path.split("/")[-1]

    # Add file reference
    file_ref_pattern = r"(/\* End PBXFileReference section \*/)"
    file_ref_entry = f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};\n'
    content = re.sub(file_ref_pattern, f"{file_ref_entry}\\1", content)

    # Add build file reference
    build_file_pattern = r"(/\* End PBXBuildFile section \*/)"
    build_file_entry = f"\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n"
    content = re.sub(build_file_pattern, f"{build_file_entry}\\1", content)

    # Add to group
    group_pattern = rf"({re.escape(group_name)} = \{{[^}}]*children = \(\s*)"
    group_entry = f"\t\t\t\t{file_ref_uuid} /* {filename} */,\n"
    content = re.sub(group_pattern, f"\\1{group_entry}", content)

    # Add to Sources build phase
    sources_pattern = r"(isa = PBXSourcesBuildPhase;[^}]*files = \(\s*)"
    sources_entry = f"\t\t\t\t{build_file_uuid} /* {filename} in Sources */,\n"
    content = re.sub(sources_pattern, f"\\1{sources_entry}", content)

    with open(project_file, "w") as f:
        f.write(content)

    print(f"Added {filename} to Xcode project")
    print(f"File Reference UUID: {file_ref_uuid}")
    print(f"Build File UUID: {build_file_uuid}")


if __name__ == "__main__":
    project_file = "MomentumFinance.xcodeproj/project.pbxproj"
    add_file_to_project(project_file, "MissingTypes.swift")
