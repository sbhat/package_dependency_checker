require 'spec/spec_helper.rb'
require 'app/java_source/package_tree.rb'

describe JavaSource::PackageTree do
  context '#<subtract_method>' do
    before :each do
      @source_package_tree = JavaSource::PackageTree.create_by('japa.parser.ast')
    end

    it "should return empty when the target package tree covers all its nodes using *" do
      target_package_tree = JavaSource::PackageTree.create_by('japa.*')
      (@source_package_tree - target_package_tree).packages.should be_empty
    end

    it "should return all its packages when the target package tree doesn't cover any of its packages" do
      target_package_tree = JavaSource::PackageTree.create_by('java.*')
      (@source_package_tree - target_package_tree).packages.should == @source_package_tree.packages
    end

    it "should return empty when the target package tree covers all its packages" do
      source_package_tree = JavaSource::PackageTree.create_by('japa.parser.Parser')
      target_package_tree = JavaSource::PackageTree.create_by('japa.parser')
      (source_package_tree - target_package_tree).packages.should be_empty
    end

    it "should return packages not covered by the target package tree when it has no * child node" do
      @source_package_tree.add('japa.parser.body.test')
      target_package_tree = JavaSource::PackageTree.create_by('japa.parser')
      (@source_package_tree - target_package_tree).packages.should == ['japa.parser.body.test']

      source_package_tree = JavaSource::PackageTree.create_by('japa.Parser')
      source_package_tree.add('japa.parser.body')
      target_package_tree = JavaSource::PackageTree.create_by('japa')
      (source_package_tree - target_package_tree).packages.should == ['japa.parser.body']
    end

    it "should return empty when its packeges exactly match with the packages of the target package tree" do
      target_package_tree = JavaSource::PackageTree.create_by('japa.parser.ast')
      (@source_package_tree - target_package_tree).packages.should be_empty
    end
  end
end
