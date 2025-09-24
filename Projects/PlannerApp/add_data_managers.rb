#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = '/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'PlannerApp' }

# Files to add
files_to_add = [
  'DataManagers/CalendarDataManager.swift',
  'DataManagers/TaskDataManager.swift'
]

files_to_add.each do |file_path|
  full_path = File.join(File.dirname(project_path), file_path)

  if File.exist?(full_path)
    # Add file reference to project
    file_ref = project.new_file(file_path)

    # Add to main target
    target.add_file_references([file_ref])

    puts "Added #{file_path} to project"
  else
    puts "File not found: #{full_path}"
  end
end

# Save the project
project.save

puts "Project saved successfully"
