#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'PlannerApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'PlannerApp' }

# Files to add
files_to_add = [
  'Components/Goals/GoalsHeaderView.swift',
  'Components/Goals/GoalsListView.swift',
  'DataManagers/JournalDataManager.swift',
  'Components/Goals/ProgressUpdateSheet.swift'
]

files_to_add.each do |file_path|
  if File.exist?(file_path)
    # Add file reference to project
    file_ref = project.new_file(file_path)

    # Add to target
    target.add_file_references([file_ref])
    puts "Added #{file_path} to project"
  else
    puts "File #{file_path} does not exist"
  end
end

# Save the project
project.save
puts "Project saved successfully"
