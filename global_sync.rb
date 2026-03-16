require 'xcodeproj'

project_path = 'Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Frutella' }

puts "Scanning disk for .swift files..."
disk_files = Dir.glob("Frutella/**/*.swift")
puts "Found #{disk_files.length} .swift files on disk."

# Ensure the Frutella group exists
frutella_group = project.main_group.children.find { |c| c.name == 'Frutella' || c.path == 'Frutella' }
unless frutella_group
  puts "Creating missing Frutella group..."
  frutella_group = project.new_group('Frutella', 'Frutella')
end

added_to_project = 0
added_to_target = 0

disk_files.each do |relative_path|
  # filename = File.basename(relative_path)
  
  # Find or create file reference
  file_ref = project.files.find { |f| f.path == relative_path }
  unless file_ref
    # Find the correct group for this file
    path_parts = relative_path.split('/')
    current_group = project.main_group
    
    path_parts[0...-1].each do |part|
      next_group = current_group.children.find { |c| c.isa == 'PBXGroup' && (c.name == part || c.path == part) }
      unless next_group
        next_group = current_group.new_group(part, part)
      end
      current_group = next_group
    end
    
    file_ref = current_group.new_file(relative_path)
    added_to_project += 1
  end
  
  # Ensure it's in target build phase
  unless target.source_build_phase.files_references.include?(file_ref)
    target.add_file_references([file_ref])
    added_to_target += 1
  end
end

project.save
puts "Added #{added_to_project} files to project, #{added_to_target} files to target."
puts "Project saved!"
