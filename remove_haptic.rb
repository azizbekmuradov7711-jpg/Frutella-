require 'xcodeproj'

project_path = './Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Frutella' }

files_to_remove = []

target.source_build_phase.files.each do |f|
  next unless f.file_ref
  path = f.file_ref.path || f.file_ref.name
  if path == 'HapticManager.swift'
    files_to_remove << f
  end
end

files_to_remove.each do |f|
  puts "Removing #{f.file_ref.path || f.file_ref.name} from project"
  f.remove_from_project
end

if files_to_remove.any?
  project.save
  puts "Saved."
end
