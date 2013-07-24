require 'spec/spec_helper.rb'
require 'java'
require 'app/java_source/sfile.rb'

describe JavaSource::SFile do
  before :each do
    @file = JavaSource::SFile.new("#{ROOT}/spec/src/japa/parser/ASTParser.java")
  end

  context "#package" do
    it "should return the package the java type defined in the file belongs to" do
      @file.package.should == 'japa.parser'
    end
  end

  context "#dependent_packages" do
    it "should return an array of dependent packages" do
      @file.dependent_packages.first.should == 'japa.parser.ast.Comment'
    end
  end
end