require 'xcodeproj'

project_path = '/Users/azizbek/Documents/Frutella/FARUTELLA/Mobile/Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'Frutella Courier' }
if target.nil?
  puts "Target Frutella Courier not found"
  exit 1
end

def add_file_to_target(project, target, file_name)
  # Поиск файла по имени во всех группах
  file_ref = project.files.find { |f| f.path && f.path.include?(file_name) }
  
  if file_ref
    if !target.source_build_phase.files_references.include?(file_ref)
      target.source_build_phase.add_file_reference(file_ref)
      puts "✅ Added #{file_name} to target"
    else
      puts "ℹ️ #{file_name} is already in target"
    end
  else
    puts "❌ Could not find file reference for #{file_name} in the project"
  end
end

files = [
    "Order.swift",
    "OrderItem.swift", 
    "OrderStatus.swift",
    "OrderHistoryView.swift",
    "SmartProductImage.swift",
    "OrderStatusProgressView.swift",
    "TrackingView.swift",
    "SkeletonOrderList.swift",
    "LocalizationManager.swift",
    "LocalizedKey.swift",
    "OrderHistoryViewModel.swift"
]

files.each do |file|
    add_file_to_target(project, target, file)
end

project.save
puts "Project saved successfully"
