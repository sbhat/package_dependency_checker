ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(ROOT)

require 'checker.rb'

source_packages = ENV['source']
source_dirs = ENV['dir']
target_packages = ENV['target']
if source_dirs.nil? || source_packages.nil? || target_packages.nil?
  puts "Please provide source directory(using 'dir=<source_dir>'), source package(using 'source=<source package>') and target packages(using 'target=<target packages>') to check for dependencies."
else
  PackageDependencyChecker.new(source_packages.split(','), source_dirs.split(','), target_packages.split(',')).report
end
