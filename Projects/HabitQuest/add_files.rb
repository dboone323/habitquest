#!/usr/bin/env ruby

require 'xcodeproj'
require 'find'

puts '🔧 Adding missing Swift files to HabitQuest Xcode project...'

# Open the project
project = Xcodeproj::Project.open('HabitQuest.xcodeproj')

# Get the main target
target = project.targets.find { |t| t.name == 'HabitQuest' }

if target.nil?
  puts '❌ Could not find HabitQuest target'
  exit 1
end

# Get the main group
main_group = project.main_group

# Find all Swift files
swift_files = []
Find.find('.') do |path|
  if path.end_with?('.swift') && !path.include?('Pods/') && !path.include?('Carthage/') && !path.include?('.xcodeproj/') && !path.include?('DerivedData/') && !path.include?('Tests/')
    swift_files << path
  end
end

puts "📋 Found #{swift_files.count} Swift files to add"

# Add files to the project
added_count = 0
swift_files.each do |file_path|
  # Skip if already in project
  next if project.files.find { |f| f.path == file_path }
  
  # Add file reference
  file_ref = project.new_file(file_path)
  
  # Add to main group
  main_group.children << file_ref
  
  # Add to target
  target.add_file_references([file_ref])
  
  added_count += 1
  puts "✅ Added: #{file_path}"
end

# Save the project
project.save

puts "🎉 Successfully added #{added_count} files to the project"
