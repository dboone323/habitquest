#!/usr/bin/env python3


def resolve_git_conflicts(file_path):
    """Resolve Git merge conflicts by keeping HEAD version"""

    with open(file_path, "r") as f:
        content = f.read()

    lines = content.split("\n")
    resolved_lines = []
    in_conflict = False
    in_head_section = False

    for line in lines:
        if line.startswith("<<<<<<< HEAD"):
            in_conflict = True
            in_head_section = True
            continue
        elif line.startswith("=======") and in_conflict:
            in_head_section = False
            continue
        elif line.startswith(">>>>>>>") and in_conflict:
            in_conflict = False
            in_head_section = False
            continue

        # Keep lines that are either not in conflict or in HEAD section
        if not in_conflict or in_head_section:
            resolved_lines.append(line)

    # Write resolved content back
    with open(file_path, "w") as f:
        f.write("\n".join(resolved_lines))

    print(f"Resolved conflicts in {file_path}")


if __name__ == "__main__":
    resolve_git_conflicts("MomentumFinance.xcodeproj/project.pbxproj")
