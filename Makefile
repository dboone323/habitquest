SHELL := /bin/zsh
.PHONY: validate lint format test
DERIVED_DATA_PATH ?= .build/DerivedData
OUTPUT_DIR ?= ../outputs/HabitQuest

validate:
	@.ci/agent_validate.sh

lint:
	@swiftlint --strict

format:
	@swiftformat . --config .swiftformat

test:
	@mkdir -p $(OUTPUT_DIR) && rm -rf $(OUTPUT_DIR)/TestResults_iOS.xcresult
	xcodebuild test \
		-project HabitQuest.xcodeproj \
		-scheme HabitQuest \
		-testPlan HabitQuest \
		-xcconfig Config/Test.xcconfig \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-destination 'platform=iOS Simulator,name=iPhone 17' \
		-resultBundlePath $(OUTPUT_DIR)/TestResults_iOS.xcresult
