require 'xcodeproj'

project_path = 'Tempestas.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Get the main group
main_group = project.main_group['Tempestas']

# Define folders and files to add
folders = {
  'Models' => Dir.glob('Tempestas/Models/*.swift'),
  'Services' => Dir.glob('Tempestas/Services/*.swift'),
  'ViewModels' => Dir.glob('Tempestas/ViewModels/*.swift'),
  'Views' => Dir.glob('Tempestas/Views/*.swift'),
  'Extensions' => Dir.glob('Tempestas/Extensions/*.swift')
}

folders.each do |folder_name, files|
  # Create or get the group
  group = main_group[folder_name] || main_group.new_group(folder_name, folder_name)
  
  files.each do |file_path|
    file_name = File.basename(file_path)
    
    # Skip if already added
    next if group.files.any? { |f| f.path == file_name }
    
    # Add file reference
    file_ref = group.new_file(file_path)
    
    # Add to build phase
    target.add_file_references([file_ref])
    
    puts "Added: #{file_path}"
  end
end

# Add Info.plist if not already there
info_plist_path = 'Tempestas/Info.plist'
if File.exist?(info_plist_path) && !main_group.files.any? { |f| f.path == 'Info.plist' }
  main_group.new_file(info_plist_path)
  puts "Added: #{info_plist_path}"
end

project.save

puts "\n✅ All files added to Xcode project!"
