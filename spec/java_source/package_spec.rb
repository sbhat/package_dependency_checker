require 'spec/spec_helper.rb'
require 'java'
require 'java_source/package.rb'

describe JavaSource::Package do
  context "#accepts?" do
    it "should accept in case of static package" do
      JavaSource::Package.new('japa.parser.ast').accepts?('japa.parser.ast').should be_true
    end

    it "should accept in case of generic package" do
      JavaSource::Package.new('japa.parser.ast.*').accepts?('japa.parser.ast.body').should be_true
    end
  end
end