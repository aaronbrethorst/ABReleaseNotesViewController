#
# Be sure to run `pod lib lint ABReleaseNotesViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ABReleaseNotesViewController"
  s.version          = "0.1.1"
  s.summary          = "The easiest way to display your App Store release notes inside your app after an update."
  s.description      = <<-DESC
Since iOS 7, users have been opted in to automatic updates of their apps from the App Store. This is great for ensuring that our users are always on the latest versions of our products, but it means that it can be much more difficult to tell them about what's new and different in our updates. ABReleaseNotesViewController fixes that by displaying your app's release notes from the App Store inside your app on the first launch after an update.
                       DESC

  s.homepage         = "https://github.com/aaronbrethorst/ABReleaseNotesViewController"
  s.screenshots      = "https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/8575/rel.jpg"
  s.license          = 'MIT'
  s.author           = { "Aaron Brethorst" => "aaron@brethorsting.com" }
  s.source           = { :git => "https://github.com/aaronbrethorst/ABReleaseNotesViewController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/aaronbrethorst'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'ABReleaseNotesViewController/**/*'
  s.public_header_files = 'ABReleaseNotesViewController/**/*.h'
  s.frameworks = 'UIKit'
end
