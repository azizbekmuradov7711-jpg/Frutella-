require 'xcodeproj'

project_path = './Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)
main_group = project.main_group

frutella_groups = main_group.children.select { |c| c.isa == 'PBXGroup' && (c.name == 'Frutella' || c.path == 'Frutella') }

if frutella_groups.count > 1
  puts "🔍 Found #{frutella_groups.count} 'Frutella' groups. Merging/Cleaning up..."
  
  # Keep the first one
  best_group = frutella_groups.first
  puts "✅ Keeping group: #{best_group.uuid} (#{best_group.display_name})"
  
  # Remove the others
  frutella_groups[1..-1].each do |group|
    puts "🗑️ Removing duplicate group: #{group.uuid} (#{group.display_name})"
    group.remove_from_project
  end
  
  project.save
  puts "✨ Project saved with single 'Frutella' group."
else
  puts "ℹ️ Only #{frutella_groups.count} 'Frutella' group found. No action needed."
end
