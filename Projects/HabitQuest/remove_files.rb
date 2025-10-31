#!/usr/bin/env ruby

require 'xcodeproj'

puts '🔧 Removing problematic test script files from HabitQuest Xcode project...'

# Open the project
project = Xcodeproj::Project.open('HabitQuest.xcodeproj')

# Get the main target
target = project.targets.find { |t| t.name == 'HabitQuest' }

if target.nil?
  puts '❌ Could not find HabitQuest target'
  exit 1
end

# Files to remove
files_to_remove = [
  './test_ai_service.swift',
  './validate_ai_features.swift'
]

removed_count = 0

files_to_remove.each do |file_path|
  # Find the file reference
  file_ref = project.files.find { |f| f.path == file_path }

  if file_ref
    # Remove from target
    target.source_build_phase.remove_file_reference(file_ref)

    # Remove from main group
    file_ref.parent.children.delete(file_ref)

    # Remove the file reference itself
    project.files.delete(file_ref)

    removed_count += 1
    puts "✅ Removed: #{file_path}"
  else
    puts "⚠️  File not found in project: #{file_path}"
  end
end

# Save the project
project.save

puts "🎉 Successfully removed #{removed_count} files from the project"
