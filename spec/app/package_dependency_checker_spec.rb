require "spec/spec_helper.rb"
require 'java'
require File.expand_path("#{ROOT}/app/package_dependency_checker.rb")

describe PackageDependencyChecker do
  before :each do
    source_packages = ['japa.parser.ast']
    source_dirs = ['./spec/src']
    target_packages = ['japa.parser.ast.*']
    @checker = PackageDependencyChecker.new(source_packages, source_dirs, target_packages)
  end

  context "#a_parent_target_package_for" do
    it "should return matching target package" do
      @checker.send(:a_parent_target_package_for, 'japa.parser.ast.body').should_not be_nil
      @checker.send(:a_parent_target_package_for, 'japa.parser.ast.body').instance_variable_get("@name").should == 'japa.parser.ast'
    end

    it "should return nil when no matching target package found" do
      @checker.send(:a_parent_target_package_for, 'japa.parser').should be_nil
    end
  end

  context "#missing_package_dependency" do
    it "should return a map of file to missing dependent packages" do
      @checker.send(:missing_package_dependency).should == { "japa.parser.ast.CompilationUnit.java"=>"java.util.List" }
    end
  end

  context "#source_filepaths" do
    it "should return source files that belong to source package" do
      expected_source_filenames = ["./spec/src/japa/parser/ast/BlockComment.java", "./spec/src/japa/parser/ast/CompilationUnit.java"]
      @checker.send('source_filepaths').should == expected_source_filenames
    end
  end

  context "#report" do
    it "should report missing dependency" do
      @checker.report(true).should == "1. japa.parser.ast.CompilationUnit.java depends on java.util.List\n"
    end
  end
end