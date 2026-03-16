require 'xcodeproj'

project_path = './Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Frutella' }

seen = {}
duplicates = []

target.source_build_phase.files.each do |f|
  next unless f.file_ref
  path = f.file_ref.path || f.file_ref.name
  if seen[path]
    duplicates << f
  else
    seen[path] = true
  end
end

duplicates.each do |f|
  puts "Removing duplicate: #{f.file_ref.path || f.file_ref.name}"
  f.remove_from_project
end

if duplicates.any?
  project.save
  puts "Saved."
end
