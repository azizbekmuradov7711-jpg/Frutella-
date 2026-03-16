require 'xcodeproj'

project_path = 'Frutella.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Frutella' }

files_to_check = [
  'AppState.swift',
  'SplashView.swift',
  'LanguageSelectionView.swift',
  'OnboardingView.swift',
  'PhoneVerificationView.swift',
  'OTPView.swift',
  'RegistrationView.swift',
  'MainTabBarView.swift'
]

puts "--- Diagnostic Report ---"
files_to_check.each do |filename|
  file_ref = project.files.find { |f| f.path.to_s.end_with?(filename) || f.name.to_s == filename }
  if file_ref.nil?
    puts "❌ #{filename}: Not found in project."
  else
    in_target = target.source_build_phase.files_references.include?(file_ref)
    puts "#{in_target ? '✅' : '🔴'} #{filename}: #{in_target ? 'In target' : 'NOT in target'} (Path: #{file_ref.path})"
  end
end
