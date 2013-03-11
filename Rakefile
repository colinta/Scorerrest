$:.unshift('/Library/RubyMotion/lib')
require 'motion/project'
require 'bundler'
Bundler.require
require 'sugarcube-gestures'


Motion::Project::App.setup do |app|
  app.name = 'Scorerrest'
  app.identifier = 'com.colinta.Scorerrest'
  app.icons = ['AppIcon-114.png', 'AppIcon-57.png', 'AppIcon-144.png', 'AppIcon-72.png']
  app.version = '1.0.0'
  app.device_family = [:iphone, :ipad]
  app.archs['iPhoneOS'] = ['armv7']

  # add local sources
  %w{lib vendor/gradient_view app}.map{|d| Dir.glob(File.join(app.project_dir, "#{d}/**/*.rb")) }.flatten.each do |file|
    app.files.push(file)
  end

  app.development do
    app.entitlements['get-task-allow'] = true
  end

  app.release do
  end

  app.frameworks << 'AVFoundation'
end

desc "Open latest crash log"
task :log do
  p "open #{Dir[File.join(ENV['HOME'], "/Library/Logs/DiagnosticReports/.Scorerrest*")].last}"
  exec "open #{Dir[File.join(ENV['HOME'], "/Library/Logs/DiagnosticReports/.Scorerrest*")].last}"
end
