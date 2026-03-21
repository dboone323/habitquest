SHELL := /bin/zsh
.PHONY: validate lint format test
DERIVED_DATA_PATH ?= .build/DerivedData
OUTPUT_DIR ?= ../outputs/HabitQuest

validate:
	@.ci/agent_validate.sh

lint:
	@swiftlint --strict || true

format:
	@swiftformat . --config .swiftformat || true

test:
	xcodebuild test \
		-project HabitQuest.xcodeproj \
		-scheme HabitQuest \
		-testPlan HabitQuest \
		-xcconfig Config/Test.xcconfig \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-destination 'platform=iOS Simulator,name=iPhone 17' \
		-resultBundlePath $(OUTPUT_DIR)/TestResults_iOS.xcresult || true
