Pod::Spec.new do |s|
   s.name = 'Masonry'
   s.version = '1.2'
   s.license = { :type => "MIT", :file => "LICENSE.md" }

   s.summary = 'Masonry/Waterfall Layout UI library for iOS.'
   s.homepage = 'https://github.com/shion0111'

   s.author = { "Antelis" => "antelis.wu@gmail.com" }

   s.source = { :git => "https://github.com/shion0111/ScaleTransitViewController.git", :tag => s.version.to_s }
   s.source_files = "Pod/Classes/"
   s.resource_bundles = {
        'Masonry' => ['Pod/Assets/*.{xib,storyboard}']
    }
   s.pod_target_xcconfig = {
      "SWIFT_VERSION" => "4.2",
   }

   s.swift_version = '4.2'

   s.ios.deployment_target = '10.0'

   s.requires_arc = true

end
