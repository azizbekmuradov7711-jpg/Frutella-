#!/usr/bin/env ruby
# Adds InfoPlist.strings files (ru/uz/en) to the Frutella Xcode project
# Usage: ruby add_infoplist_strings.rb

require 'xcodeproj'

PROJECT_PATH = File.expand_path("../Frutella.xcodeproj", __FILE__)
TARGET_NAME  = "Frutella"

# Files to add (relative to Frutella/ folder)
FILES = {
  "ru.lproj/InfoPlist.strings" => "Frutella/ru.lproj/InfoPlist.strings",
  "uz.lproj/InfoPlist.strings" => "Frutella/uz.lproj/InfoPlist.strings",
  "en.lproj/InfoPlist.strings" => "Frutella/en.lproj/InfoPlist.strings",
}

project = Xcodeproj::Project.open(PROJECT_PATH)
target  = project.targets.find { |t| t.name == TARGET_NAME }

unless target
  puts "❌ Target '#{TARGET_NAME}' not found!"
  exit 1
end

# Find or create the "Resources" build phase
resources_phase = target.resources_build_phase

FILES.each do |display_name, relative_path|
  abs_path = File.join(File.dirname(PROJECT_PATH), relative_path)
  
  unless File.exist?(abs_path)
    puts "⚠️  File not found, skipping: #{abs_path}"
    next
  end

  # Check if already in project
  already_added = project.files.any? { |f| f.real_path.to_s == abs_path }
  if already_added
    puts "✅ Already in project: #{display_name}"
    next
  end

  # Add file reference to the correct group
  lproj_name = File.dirname(relative_path)           # e.g. "Frutella/ru.lproj"
  group_path  = lproj_name.split("/")

  # Traverse / create group hierarchy
  group = project.main_group
  group_path.each do |part|
    existing = group.children.find { |c| c.respond_to?(:name) && c.name == part }
    group = existing || group.new_group(part)
  end

  file_ref = group.new_file(abs_path)
  file_ref.last_known_file_type = "text.plistStrings"

  # Add to Resources build phase
  resources_phase.add_file_reference(file_ref)

  puts "➕ Added: #{display_name}"
end

project.save
puts "\n🎉 Done! Project saved: #{PROJECT_PATH}"
