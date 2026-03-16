require 'xcodeproj'

project_path = '/Users/azizbek/Documents/Frutella/FARUTELLA/Mobile/Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Dictionary to store file names and their found paths relative to project root
file_paths = {}

puts "Searching for files in the filesystem..."
Dir.glob('/Users/azizbek/Documents/Frutella/FARUTELLA/Mobile/Frutella/**/*').each do |full_path|
  if File.file?(full_path)
    file_name = File.basename(full_path)
    # Store the path relative to the PROJECT root (which is Mobile folder)
    # project_path is in Mobile/Frutella.xcodeproj
    # Files are in Mobile/Frutella/...
    relative_path = full_path.gsub('/Users/azizbek/Documents/Frutella/FARUTELLA/Mobile/', '')
    file_paths[file_name] = relative_path
  end
end

puts "Updating project file references..."
project.files.each do |file_ref|
  # Only try to fix if it's a source file and our found paths contains it
  next unless file_ref.path
  
  file_name = File.basename(file_ref.path)
  if file_paths[file_name]
    if file_ref.path != file_paths[file_name]
      puts "Fixing path: #{file_ref.path} -> #{file_paths[file_name]}"
      file_ref.path = file_paths[file_name]
      file_ref.source_tree = '<group>'
    end
  end
end

project.save
puts "✅ Project file paths updated successfully!"
