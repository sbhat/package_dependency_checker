require 'java_source/sfile.rb'
require 'java_source/package.rb'

class PackageDependencyChecker
  def initialize source_packages, source_dirs, target_packages
    @source_packages = source_packages
    @source_dirs = source_dirs
    @target_packages = target_packages.map{|package| JavaSource::Package.new(package)}
  end

  def get_missing_package_dependency
    source_files.inject({}) do |map, file|
      missing_packages = missing_dependent_packages(file)
      map["#{file.package}.#{file.name}"] =  missing_packages.join(',') unless missing_packages.empty?
      map
    end
  end

  def report suppress_stdout = false
    output = ""
    counter = 0
    get_missing_package_dependency.each{|name, dependency| counter+=1; output << "#{counter}. #{name} depends on #{dependency}\n"}
    puts output unless suppress_stdout
    output
  end

  private

  def missing_dependent_packages java_file
    jimports = java_file.dependent_packages
    jimports.select { |jpackage| !belongs_to_target_packages?(jpackage) }
  end

  def source_files
    source_filenames.map {|file_name| JavaSource::SFile.new(file_name)}
  end

  def belongs_to_target_packages? pkg
    accepts = false 
    @target_packages.map{|package| accepts ||= package.accepts?(pkg)}
    accepts
  end

  def source_filenames
    @source_dirs.map do |source_dir|
      @source_packages.map do |source_package|
        source_dir_path = "#{source_dir}/#{source_package.split('.').join('/')}"
        Dir["#{source_dir_path}/**/*.java"].select{|file_path| !File.directory?(file_path)}
      end
    end.flatten
  end
end
