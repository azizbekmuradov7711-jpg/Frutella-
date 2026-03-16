require 'xcodeproj'

project_path = '/Users/azizbek/Documents/Frutella/FARUTELLA/Mobile/Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 1. Find the main target
target = project.targets.find { |t| t.name == 'Frutella' }
if target.nil?
  puts "❌ Target 'Frutella' not found"
  exit 1
end

# 2. Re-create Products group if it's missing or messed up
products_group = project.main_group.find_subpath('Products', true)
products_group.name = 'Products'
products_group.source_tree = 'BUILT_PRODUCTS_DIR' # Standard for Products group

# 3. Ensure Frutella.app exists in Products group and is linked to the target
app_name = 'Frutella.app'
app_ref = products_group.files.find { |f| f.path == app_name }

if app_ref.nil?
  puts "Creating missing PBXFileReference for #{app_name}..."
  app_ref = products_group.new_reference(app_name)
  app_ref.include_in_index = '0'
  app_ref.last_known_file_type = 'wrapper.application'
end

if target.product_reference.nil? || target.product_reference.path != app_name
  puts "Linking target to product reference..."
  target.product_reference = app_ref
end

# 4. Fix Project-level settings
project.build_configurations.each do |config|
  puts "Updating project config: #{config.name}"
  config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
  config.build_settings['SDKROOT'] = 'iphoneos'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
end

# 5. Ensure the project's product_ref_group points to the Products group
project.root_object.product_ref_group = products_group

# Save changes
project.save
puts "✅ Project fixed and saved successfully!"
