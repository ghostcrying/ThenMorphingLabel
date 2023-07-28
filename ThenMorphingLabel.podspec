Pod::Spec.new do |s|
  s.name             = 'ThenMorphingLabel'
  s.version          = '0.0.1'
  s.summary          = 'The UILabel with Morphing.'

  s.description      = <<-DESC
Fork
                       DESC

  s.homepage      = 'https://github.com/ghostcrying/ThenMorphingLabel'
  # s.screenshots = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.author        = { 'ghost' => 'czios1501@gmail.com' }
  s.source        = { :git => 'https://github.com/ghostcrying/ThenMorphingLabel.git', :tag => s.version.to_s }
  
  s.platform      = :ios, "11.0"
  s.swift_version = "5.0"

  s.source_files  = 'Sources/**/*.{swift}'
  
  s.resources     = "Sources/Particles/*.png"
  s.frameworks    = "UIKit", "Foundation", "QuartzCore"
  
end

