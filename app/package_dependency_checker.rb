require 'app/java_source/sfile.rb'
require 'app/java_source/package.rb'
require 'lib/ruby/java_lib.rb'

class PackageDependencyChecker
  def initialize source_packages, source_dirs, target_packages
    @source_packages = source_packages
    @source_dirs = source_dirs
    @target_packages = target_packages.map{|package| JavaSource::Package.new(package)}
  end

  def report suppress_stdout = false
    output, counter = "", 0
    missing_package_dependency.each{|name, dependency| counter+=1; output << "#{counter}. #{name} depends on #{dependency}\n"}
    puts output unless suppress_stdout
    output
  end

  private

  def missing_package_dependency
    {}.tap do |dependency_map|
      source_files.each do |sfile|
        missing_packages = missing_dependent_packages_for(sfile)
        dependency_map["#{sfile.source_package}.#{sfile.name}"] =  missing_packages.join(',') unless missing_packages.empty?
      end
    end
  end

  def missing_dependent_packages_for java_file
    jimport_declarations = java_file.import_declarations
    missing_dependent_packages = jimport_declarations.select do |jimport_declaration|
      dependent_package = jimport_declaration.name.qualifier.to_s
      !belongs_to_target_packages?(dependent_package)
    end
    missing_dependent_packages.map{|package| package.name.to_s}
  end

  def belongs_to_target_packages? package
    !a_parent_target_package_for(package).nil?
  end

  def a_parent_target_package_for package
    @target_packages.detect{|target_package| target_package.matches_or_contains?(package)}
  end

  def source_files
    source_filepaths.map do |file_name|
      begin
        JavaSource::SFile.new(file_name)
      rescue JavaLib::ParseException => e
        puts "[Warning] Failed to parse the java file #{file_name}!!"
        nil
      end
    end.compact
  end

  def source_filepaths
    @source_dirs.map do |source_dir|
      @source_packages.map do |source_package|
        source_dir_path = "#{source_dir}/#{source_package.split('.').join('/')}"
        Dir["#{source_dir_path}/**/*.java"].select{|file_path| !File.directory?(file_path)}
      end
    end.flatten
  end
end
