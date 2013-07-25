require 'spec/spec_helper.rb'
require 'java'
require 'app/java_source/sfile.rb'

describe JavaSource::SFile do
  before :each do
    @file = JavaSource::SFile.new("#{ROOT}/spec/src/japa/parser/ASTParser.java")
  end

  context "#source_package" do
    it "should return the package the java type defined in the file belongs to" do
      @file.source_package.should == 'japa.parser'
    end
  end

  context "#import_declarations" do
    it "should return an array of dependent packages" do
      @file.import_declarations.first.name.to_s.should == 'japa.parser.ast.Comment'
    end
  end
end