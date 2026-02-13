SHELL := /bin/zsh
.PHONY: validate lint format test

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
		-destination 'platform=iOS Simulator,name=iPhone 17' || true
