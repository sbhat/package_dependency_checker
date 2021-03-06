require 'spec/spec_helper.rb'
require 'java'
require 'app/java_source/java_file.rb'

describe JavaSource::JavaFile do
  before :each do
    @file = JavaSource::JavaFile.new("#{ROOT}/spec/src/japa/parser/ASTParser.java")
  end

  context "#source_package" do
    it "should return the package the java type defined in the file belongs to" do
      @file.source_package.should == 'japa.parser'
    end
  end

  context "#dependent_packages" do
    it "should return an array of dependent packages" do
      @file.dependent_packages.first.should == 'japa.parser.ast.Comment'
    end
  end
end