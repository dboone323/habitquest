#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = '/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/PlannerApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'PlannerApp' }

# Components to add
components_to_add = [
  'Components/Dashboard/UpcomingItemView.swift',
  'Components/Tasks/TaskManagerHeaderView.swift',
  'Components/Tasks/TaskInputView.swift',
  'Components/Tasks/TaskListView.swift'
]

components_to_add.each do |component_path|
  full_path = File.join(File.dirname(project_path), component_path)

  if File.exist?(full_path)
    # Add file reference to project
    file_ref = project.main_group.find_file_by_path(component_path) || project.main_group.new_file(component_path)

    # Add to target if not already added
    unless target.source_build_phase.files_references.include?(file_ref)
      target.source_build_phase.add_file_reference(file_ref)
      puts "Added #{component_path} to project"
    else
      puts "#{component_path} already in project"
    end
  else
    puts "File not found: #{full_path}"
  end
end

# Save the project
project.save
puts "Project saved successfully"
