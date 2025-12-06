#!/usr/bin/env ruby

require 'xcodeproj'
require 'find'

# Open the project
project_path = 'HabitQuest.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'HabitQuest' }

if target.nil?
  puts "❌ Could not find HabitQuest target"
  exit 1
end

# Get the main group
main_group = project.main_group

# Prune missing files
project.files.each do |file|
  next if file.path.nil?
  
  full_path = file.real_path
  if !File.exist?(full_path)
    puts "🗑️ Removing missing file: #{file.path}"
    file.remove_from_project
  end
end

# Find all Swift files
swift_files = []
Find.find('.') do |path|
  if path.end_with?('.swift') && !path.include?('Pods/') && !path.include?('Carthage/') && !path.include?('.xcodeproj/') && !path.include?('DerivedData/')
    # Remove leading ./ if present
    clean_path = path.start_with?('./') ? path[2..-1] : path
    swift_files << clean_path
  end
end

puts "📋 Found #{swift_files.count} Swift files to add"

# Add files to the project
added_count = 0
swift_files.each do |file_path|
  # Skip if already in project
  abs_file_path = File.expand_path(file_path)
  next if project.files.find { |f| f.real_path.to_s == abs_file_path }

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
