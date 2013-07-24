ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(ROOT)

require 'checker.rb'

source_package = ENV['source']
source_dir = ENV['dir']
target_packages = ENV['target']
if source_dir.nil? || source_package.nil? || target_packages.nil?
  puts "Please provide source directory(using 'dir=<source_dir>'), source package(using 'source=<source package>') and target packages(using 'target=<target packages>') to check for dependencies."
else
  Checker.new(source_package, source_dir, target_packages.split(',')).report
end
