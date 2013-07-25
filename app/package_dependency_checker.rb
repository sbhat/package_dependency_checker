require 'app/java_source/java_file.rb'
require 'app/java_source/package_tree.rb'
require 'lib/ruby/java_lib.rb'

class PackageDependencyChecker
  def initialize source_packages, source_dirs, target_packages
    @source_packages = source_packages
    @source_dirs = source_dirs

    @target_package_tree = JavaSource::PackageTree.new
    target_packages.each{|package| @target_package_tree.add(package)}
  end

  def report suppress_stdout = false
    output, counter = "", 0
    missing_package_dependency.each{|name, dependency| counter+=1; output << "#{counter}. #{name} depends on #{dependency}\n"}
    output << "No missing package dependency." if output == ""
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
      source_package_tree = JavaSource::PackageTree.create_by(jimport_declaration.name.qualifier.to_s)
      !(source_package_tree-@target_package_tree).packages.empty?
    end
    missing_dependent_packages.map{|package| package.name.to_s}
  end

  def source_files
    filepaths = source_filepaths
    puts "[Warning] No java files found under source packages!!" if filepaths.empty?
    filepaths.map do |file_name|
      begin
        JavaSource::JavaFile.new(file_name)
      rescue JavaLib::ParseException => e
        puts "[Warning] Failed to parse java file #{file_name}!!"
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
