require 'spec/spec_helper.rb'
require 'java'
require 'app/java_source/package.rb'

describe JavaSource::Package do
  context "@has_asteric" do
    it "should be set to true when the name ends with .*" do
      JavaSource::Package.new('japa.parser.ast.*').instance_variable_get("@match_child_packages").should be_true
      JavaSource::Package.new('japa.parser.ast.*.st').instance_variable_get("@match_child_packages").should be_false
    end

    it "should be set to false when the name represents a static package list" do
      JavaSource::Package.new('japa.parser.ast').instance_variable_get("@match_child_packages").should be_false
    end
  end

  context "#parent_of?" do
    context " in case of asteric in the name" do
      it "should return true for qualifier same as the parent" do
        JavaSource::Package.new('japa.parser.ast.*').matches_or_contains?('japa.parser.ast').should be_true
      end

      it "should return false for qualifier parent of the target package" do
        JavaSource::Package.new('japa.parser.ast.*').matches_or_contains?('japa.parser').should be_false
      end

      it "should return false for qualifier is not part of the target package" do
        JavaSource::Package.new('japa.parser.ast.*').matches_or_contains?('java.util').should be_false
      end

      it "should return true for qualifiers that are a subset of the parent" do
        JavaSource::Package.new('japa.parser.ast.*').matches_or_contains?('japa.parser.ast.body').should be_true
      end
    end

    context " in case of static name" do
      it "should return true when matches with the static package" do
        JavaSource::Package.new('japa.parser.ast').matches_or_contains?('japa.parser.ast').should be_true
      end

      it "should return false when is a subset of the static package" do
        JavaSource::Package.new('japa.parser.ast').matches_or_contains?('japa.parser.ast.body').should be_false
      end
    end
  end
end