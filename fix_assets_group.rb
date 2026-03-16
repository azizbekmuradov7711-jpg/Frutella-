require 'xcodeproj'

project_path = './Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Frutella' }

# Find the group currently named Assets.xcassets
assets_group = nil
group_parent = nil

project.main_group.recursive_children.each do |child|
  if child.is_a?(Xcodeproj::Project::Object::PBXGroup) && (child.path == 'Assets.xcassets' || child.name == 'Assets.xcassets')
    assets_group = child
    group_parent = child.parent
    break
  end
end

if assets_group && group_parent
  puts "Found Assets.xcassets as PBXGroup. Converting to PBXFileReference..."
  
  # Identify the parent to re-add appropriately
  
  # 1. Remove the group
  assets_group.remove_from_project
  
  # 2. Add as file reference
  new_assets_ref = group_parent.new_file('Assets.xcassets')
  new_assets_ref.last_known_file_type = 'folder.assetcatalog'
  
  # 3. Add to Resources build phase
  resources_phase = target.resources_build_phase
  unless resources_phase.files.any? { |bf| bf.file_ref == new_assets_ref }
    resources_phase.add_file_reference(new_assets_ref)
  end
  
  project.save
  puts "Successfully fixed Assets.xcassets file type!"
else
  puts "Could not find Assets.xcassets as PBXGroup."
end
