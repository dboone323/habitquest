#!/bin/bash
# API Documentation Generator
# Generates comprehensive API documentation for all projects

set -e

WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
DOCS_DIR="${WORKSPACE_ROOT}/Documentation/API"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📚 Generating API Documentation${NC}"
echo "=================================="
echo ""

# Create documentation directories
mkdir -p "${DOCS_DIR}/Generated/${TIMESTAMP}"
mkdir -p "${DOCS_DIR}/Assets"

# Function to extract Swift documentation
generate_swift_docs() {
    local project_name=$1
    local project_path=$2
    local output_file="${DOCS_DIR}/Generated/${TIMESTAMP}/${project_name}_API.md"

    echo -e "${YELLOW}Generating documentation for ${project_name}...${NC}"

    # Start documentation file
    cat >"${output_file}" <<EOF
# ${project_name} API Documentation

**Generated:** $(date)
**Version:** 1.0.0

## Overview

This document provides comprehensive API reference for ${project_name}.

---

EOF

    # Find all Swift files
    local swift_files
    swift_files=$(find "${project_path}" -name "*.swift" -type f | grep -v "Tests" | grep -v ".build")

    local file_count=0

    # Process each Swift file
    for swift_file in $swift_files; do
        local filename
        filename=$(basename "${swift_file}")
        local relative_path="${swift_file#"${project_path}"/}"

        # Extract protocols
        local protocols
        protocols=$(grep -E "^protocol\s+\w+" "${swift_file}" 2>/dev/null || true)

        # Extract classes
        local classes
        classes=$(grep -E "^class\s+\w+" "${swift_file}" 2>/dev/null || true)

        # Extract structs
        local structs
        structs=$(grep -E "^struct\s+\w+" "${swift_file}" 2>/dev/null || true)

        # Extract enums
        local enums
        enums=$(grep -E "^enum\s+\w+" "${swift_file}" 2>/dev/null || true)

        # Extract actors
        local actors
        actors=$(grep -E "^actor\s+\w+" "${swift_file}" 2>/dev/null || true)

        # If file contains any public API elements, document it
        if [ -n "$protocols" ] || [ -n "$classes" ] || [ -n "$structs" ] || [ -n "$enums" ] || [ -n "$actors" ]; then
            ((file_count++))

            echo "## ${filename}" >>"${output_file}"
            echo "" >>"${output_file}"
            echo "**Path:** \`${relative_path}\`" >>"${output_file}"
            echo "" >>"${output_file}"

            # Extract file-level documentation
            local file_doc
            file_doc=$(awk '/^\/\/\// && !found {print; getline; while (/^\/\/\//) {print; getline} found=1}' "${swift_file}" 2>/dev/null | sed 's/^\/\/\/ *//' || true)

            if [ -n "$file_doc" ]; then
                echo "### Description" >>"${output_file}"
                echo "" >>"${output_file}"
                echo "$file_doc" >>"${output_file}"
                echo "" >>"${output_file}"
            fi

            # Document protocols
            if [ -n "$protocols" ]; then
                echo "### Protocols" >>"${output_file}"
                echo "" >>"${output_file}"

                while IFS= read -r proto_line; do
                    local proto_name
                    proto_name=$(echo "$proto_line" | awk '{print $2}' | cut -d':' -f1)
                    echo "#### \`${proto_name}\`" >>"${output_file}"
                    echo "" >>"${output_file}"

                    # Extract protocol documentation
                    local proto_doc
                    proto_doc=$(grep -B 10 "^protocol ${proto_name}" "${swift_file}" | grep "^///" | sed 's/^\/\/\/ *//' || true)
                    if [ -n "$proto_doc" ]; then
                        echo "$proto_doc" >>"${output_file}"
                        echo "" >>"${output_file}"
                    fi

                    # Extract protocol methods
                    local in_protocol=false
                    local brace_count=0
                    while IFS= read -r line; do
                        if [[ "$line" =~ ^protocol[[:space:]]+${proto_name} ]]; then
                            in_protocol=true
                        fi

                        if $in_protocol; then
                            if [[ "$line" == *"{"* ]]; then
                                ((brace_count++))
                            fi

                            if [[ "$line" =~ ^[[:space:]]*(func|var|associatedtype) ]]; then
                                local member
                                member=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/{.*//')
                                echo "- \`${member}\`" >>"${output_file}"
                            fi

                            if [[ "$line" == *"}"* ]]; then
                                ((brace_count--))
                                if [ $brace_count -eq 0 ]; then
                                    break
                                fi
                            fi
                        fi
                    done <"${swift_file}"

                    echo "" >>"${output_file}"
                done <<<"$protocols"
            fi

            # Document classes
            if [ -n "$classes" ]; then
                echo "### Classes" >>"${output_file}"
                echo "" >>"${output_file}"

                while IFS= read -r class_line; do
                    local class_name
                    class_name=$(echo "$class_line" | awk '{print $2}' | cut -d':' -f1 | cut -d'<' -f1)
                    echo "#### \`${class_name}\`" >>"${output_file}"
                    echo "" >>"${output_file}"

                    # Extract class documentation
                    local class_doc
                    class_doc=$(grep -B 10 "^class ${class_name}" "${swift_file}" | grep "^///" | sed 's/^\/\/\/ *//' || true)
                    if [ -n "$class_doc" ]; then
                        echo "$class_doc" >>"${output_file}"
                        echo "" >>"${output_file}"
                    fi

                    echo "" >>"${output_file}"
                done <<<"$classes"
            fi

            # Document structs
            if [ -n "$structs" ]; then
                echo "### Structs" >>"${output_file}"
                echo "" >>"${output_file}"

                while IFS= read -r struct_line; do
                    local struct_name
                    struct_name=$(echo "$struct_line" | awk '{print $2}' | cut -d':' -f1 | cut -d'<' -f1)
                    echo "#### \`${struct_name}\`" >>"${output_file}"
                    echo "" >>"${output_file}"

                    # Extract struct documentation
                    local struct_doc
                    struct_doc=$(grep -B 10 "^struct ${struct_name}" "${swift_file}" | grep "^///" | sed 's/^\/\/\/ *//' || true)
                    if [ -n "$struct_doc" ]; then
                        echo "$struct_doc" >>"${output_file}"
                        echo "" >>"${output_file}"
                    fi

                    echo "" >>"${output_file}"
                done <<<"$structs"
            fi

            # Document enums
            if [ -n "$enums" ]; then
                echo "### Enums" >>"${output_file}"
                echo "" >>"${output_file}"

                while IFS= read -r enum_line; do
                    local enum_name
                    enum_name=$(echo "$enum_line" | awk '{print $2}' | cut -d':' -f1)
                    echo "#### \`${enum_name}\`" >>"${output_file}"
                    echo "" >>"${output_file}"

                    # Extract enum documentation
                    local enum_doc
                    enum_doc=$(grep -B 10 "^enum ${enum_name}" "${swift_file}" | grep "^///" | sed 's/^\/\/\/ *//' || true)
                    if [ -n "$enum_doc" ]; then
                        echo "$enum_doc" >>"${output_file}"
                        echo "" >>"${output_file}"
                    fi

                    echo "" >>"${output_file}"
                done <<<"$enums"
            fi

            # Document actors
            if [ -n "$actors" ]; then
                echo "### Actors" >>"${output_file}"
                echo "" >>"${output_file}"

                while IFS= read -r actor_line; do
                    local actor_name
                    actor_name=$(echo "$actor_line" | awk '{print $2}' | cut -d':' -f1)
                    echo "#### \`${actor_name}\`" >>"${output_file}"
                    echo "" >>"${output_file}"

                    # Extract actor documentation
                    local actor_doc
                    actor_doc=$(grep -B 10 "^actor ${actor_name}" "${swift_file}" | grep "^///" | sed 's/^\/\/\/ *//' || true)
                    if [ -n "$actor_doc" ]; then
                        echo "$actor_doc" >>"${output_file}"
                        echo "" >>"${output_file}"
                    fi

                    echo "" >>"${output_file}"
                done <<<"$actors"
            fi

            echo "---" >>"${output_file}"
            echo "" >>"${output_file}"
        fi
    done

    echo "  ✅ Documented ${file_count} files"

    # Copy to main API directory
    cp "${output_file}" "${DOCS_DIR}/${project_name}_API.md"
}

# Generate documentation for each project
echo -e "${YELLOW}Scanning projects...${NC}"
echo ""

if [ -d "${WORKSPACE_ROOT}/Projects/AvoidObstaclesGame" ]; then
    generate_swift_docs "AvoidObstaclesGame" "${WORKSPACE_ROOT}/Projects/AvoidObstaclesGame"
fi

if [ -d "${WORKSPACE_ROOT}/Projects/HabitQuest" ]; then
    generate_swift_docs "HabitQuest" "${WORKSPACE_ROOT}/Projects/HabitQuest"
fi

if [ -d "${WORKSPACE_ROOT}/Projects/PlannerApp" ]; then
    generate_swift_docs "PlannerApp" "${WORKSPACE_ROOT}/Projects/PlannerApp"
fi

if [ -d "${WORKSPACE_ROOT}/Projects/MomentumFinance" ]; then
    generate_swift_docs "MomentumFinance" "${WORKSPACE_ROOT}/Projects/MomentumFinance"
fi

if [ -d "${WORKSPACE_ROOT}/Projects/CodingReviewer" ]; then
    generate_swift_docs "CodingReviewer" "${WORKSPACE_ROOT}/Projects/CodingReviewer"
fi

# Generate shared components documentation
if [ -d "${WORKSPACE_ROOT}/Shared" ]; then
    generate_swift_docs "SharedComponents" "${WORKSPACE_ROOT}/Shared"
fi

# Generate master index
echo -e "${YELLOW}Generating master index...${NC}"

cat >"${DOCS_DIR}/README.md" <<EOF
# API Documentation Index

**Generated:** $(date)

## Available Documentation

### Projects

EOF

for api_file in "${DOCS_DIR}"/*_API.md; do
    if [ -f "$api_file" ]; then
        project_name=$(basename "$api_file" _API.md)
        echo "- [${project_name}](./${project_name}_API.md)" >>"${DOCS_DIR}/README.md"
    fi
done

cat >>"${DOCS_DIR}/README.md" <<EOF

## Documentation Standards

All API documentation follows these conventions:

- **Protocols**: Public interfaces and contracts
- **Classes**: Reference types and their responsibilities
- **Structs**: Value types and data structures
- **Enums**: Enumerated types and state machines
- **Actors**: Thread-safe components for concurrent access

## Usage

1. Navigate to specific project documentation
2. Search for type or protocol name
3. Review method signatures and descriptions
4. Check usage examples where available

## Maintenance

Documentation is auto-generated from source code comments. To update:

\`\`\`bash
./Tools/generate_api_docs.sh
\`\`\`

EOF

echo ""
echo -e "${GREEN}✅ API documentation generated${NC}"
echo ""
echo "📋 Documentation locations:"
echo "  - Main index: ${DOCS_DIR}/README.md"
echo "  - Generated docs: ${DOCS_DIR}/"
echo "  - Timestamped backup: ${DOCS_DIR}/Generated/${TIMESTAMP}/"
echo ""
