ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(ROOT)

require 'app/package_dependency_checker.rb'

source_packages, source_dirs, target_packages = ENV['source'], ENV['dir'], ENV['target']
if source_dirs.nil? || source_packages.nil? || target_packages.nil?
  puts "Please provide source directory(using 'dir=<source_dir>'), source package(using 'source=<source package>') and target packages(using 'target=<target packages>') to check for dependencies."
else
  PackageDependencyChecker.new(source_packages.split(','), source_dirs.split(','), target_packages.split(',')).report
end
