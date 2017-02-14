# Use the --use-libraries switch when pushing or linting this podspec

Pod::Spec.new do |s|

  s.name         = 'IGRFilterCombine'
  s.version      = '0.1.1'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = 'Shader Filters View'

  s.description  = <<-DESC
                   IGRFilterCombine provides:
                   * Apply Instagram like filters
                   DESC

  s.homepage            = 'https://igrsoft.com'
  s.social_media_url    = 'https://twitter.com/ikorich'
  s.author              = 'Vitalii Parovishnyk'

  s.platform                = :ios, '9.0'
  s.source                  = { :git => 'https://github.com/IGRSoft/IGRFilterCombine.git',
                                :tag => s.version
                            }

  s.public_header_files     = 'IGRFilterCombine/*.h', 'IGRFilterCombine/CustomViews/*.h'
  s.source_files            = 'IGRFilterCombine/**/*.{h,m}'
  s.resources               = 'Resources/IGRFilterCombineResources.bundle'
  s.requires_arc            = true
  s.weak_frameworks         = 'UIKit', 'Foundation', 'CoreGraphics'

  s.ios.dependency 'GPUImage', '0.1.7'
end
