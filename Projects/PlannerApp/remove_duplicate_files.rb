#!/usr/bin/env ruby

require 'xcodeproj'

# Path to the Xcode project
project_path = '/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Files to remove from the project
files_to_remove = [
  'DataManagers/CalendarDataManager.swift',
  'DataManagers/TaskDataManager.swift'
]

# Get the main target
target = project.targets.first

files_to_remove.each do |file_path|
  # Find the file reference
  file_ref = project.files.find { |f| f.path == file_path }

  if file_ref
    puts "Removing #{file_path} from Xcode project..."
    # Remove from target
    target.source_build_phase.remove_file_reference(file_ref)
    # Remove from project
    file_ref.remove_from_project
  else
    puts "File #{file_path} not found in project"
  end
end

# Save the project
project.save
puts "Project updated successfully!"
