#
# Be sure to run `pod lib lint ScrollingStackViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ScrollingStackViewController'
  s.version          = '4.1.0'
  s.summary          = 'A view controller that uses root views of child view controllers as views in a UIStackView.'

  s.description      = <<-DESC
This view controller is more suitable than an UITableViewController when creating a list of segments that are dynamically behaving, but are well defined and bound in number. The delegation pattern that the data source of an UITableViewController is best suited for situation when there is an unbounded number of cells, but in many cases is an overkill and becomes a burden. Also, UITableViewCells are not controllers, but sometimes it makes sense to properly partition the responsibility of the segments, not just over the view layer. Using ScrollingStackViewController you can have a bunch of view controllers, each of them encapsulating their own responsibilities.
                       DESC

  s.homepage         = 'https://github.com/justeat/ScrollingStackViewController'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Just Eat iOS team' => 'justeat.ios.team@gmail.com', 'Maciej Trybilo' => 'maciej.trybilo@just-eat.com', 'Julien Regnauld' => 'julien.regnauld@just-eat.com' }
  s.source           = { :git => 'https://github.com/justeat/ScrollingStackViewController.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'ScrollingStackViewController/Classes/**/*'
end
