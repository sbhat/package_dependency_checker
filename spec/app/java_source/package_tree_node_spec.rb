require 'spec/spec_helper.rb'
require 'app/java_source/package_tree_node.rb'

describe JavaSource::PackageTreeNode do
  context '# \'-\' ' do
    before :each do
      @node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)
    end

    it "should return nil when it matches with the target node with match all child node" do
      target_node = JavaSource::PackageTreeNode.add('japa', nil, '*', 0)
      (@node - target_node).should be_nil
    end

    it "should return nil when it doesn't matches with the target node" do
      target_node = JavaSource::PackageTreeNode.add('java', nil, '*', 0)
      node_clone = @node - target_node

      node_clone.instance_variable_get("@name").should == 'japa'
      node_clone.instance_variable_get("@level").should == 0
      node_clone.instance_variable_get("@parent_node").should be_nil

      child_nodes = node_clone.instance_variable_get("@child_nodes")
      child_nodes.size.should == 1
      child_node = child_nodes.first
      child_node.should_not be_nil
      child_node.instance_variable_get("@name").should == 'parser'
      child_node.instance_variable_get("@level").should == 1
      child_node.instance_variable_get("@parent_node").should == node_clone

      parent_node = child_node
      child_nodes = child_node.instance_variable_get("@child_nodes")
      child_nodes.size.should == 1
      child_node = child_nodes.first
      child_node.should_not be_nil
      child_node.instance_variable_get("@name").should == 'ast'
      child_node.instance_variable_get("@level").should == 2
      child_node.instance_variable_get("@parent_node").should == parent_node

    end

    it "should return nil when it matches a leaf target node and has no non leaf child nodes" do
      target_node = JavaSource::PackageTreeNode.add('japa', nil, 'parser', 0)
      (@node - target_node).should be_nil
    end

    it "should return clone itself with left join of its child nodes with child nodes of the target node" do
      @node.add_child_node_hierarchy('parser.body.test')
      # child_nodes = node.instance_variable_get("@child_nodes")
      # child_nodes.size.should == 2
      target_node = JavaSource::PackageTreeNode.add('japa', nil, 'parser', 0)

      new_node = @node - target_node

      new_node.should_not be_nil
      new_node.instance_variable_get("@name").should == 'japa'
      new_node.instance_variable_get("@level").should == 0
      new_node.instance_variable_get("@parent_node").should be_nil
      child_nodes = new_node.instance_variable_get("@child_nodes")
      child_nodes.size.should == 1
      child_node = child_nodes.first
      child_node.should_not be_nil
      child_node.instance_variable_get("@name").should == 'parser'
      child_node.instance_variable_get("@level").should == 1
      child_node.instance_variable_get("@parent_node").should == new_node
      
      parent_node = child_node
      child_nodes = child_node.instance_variable_get("@child_nodes")
      child_nodes.size.should == 1
      child_node = child_nodes.first
      child_node.should_not be_nil
      child_node.instance_variable_get("@name").should == 'body'
      child_node.instance_variable_get("@level").should == 2
      child_node.instance_variable_get("@parent_node").should == parent_node

      parent_node = child_node
      child_nodes = child_node.instance_variable_get("@child_nodes")
      child_nodes.size.should == 1
      child_node = child_nodes.first
      child_node.should_not be_nil
      child_node.instance_variable_get("@name").should == 'test'
      child_node.instance_variable_get("@level").should == 3
      child_node.instance_variable_get("@parent_node").should == parent_node
    end

    it "should return new node with non leaf child nodes when it matches a leaf target node" do
      node = JavaSource::PackageTreeNode.add('japa', nil, 'Parser', 0)
      node.add_child_node_hierarchy('parser.body')
      child_nodes = node.instance_variable_get("@child_nodes")
      child_nodes.size.should == 2
      target_node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)

      new_node = node - target_node

      new_node.should_not be_nil
      new_node.instance_variable_get("@name").should == 'japa'
      new_node.instance_variable_get("@level").should == 0
      new_node.instance_variable_get("@parent_node").should be_nil
      child_nodes = new_node.instance_variable_get("@child_nodes")
      child_nodes.size.should == 1
      child_node = child_nodes.first
      child_node.should_not be_nil
      child_node.instance_variable_get("@name").should == 'parser'
      child_node.instance_variable_get("@level").should == 1
      child_node.instance_variable_get("@parent_node").should == new_node
      
      parent_node = child_node
      child_nodes = child_node.instance_variable_get("@child_nodes")
      child_nodes.size.should == 1
      child_node = child_nodes.first
      child_node.should_not be_nil
      child_node.instance_variable_get("@name").should == 'body'
      child_node.instance_variable_get("@level").should == 2
      child_node.instance_variable_get("@parent_node").should == parent_node
    end

    it "should return nil when it matches a target node with exact child node structure" do
      @node.add_child_node_hierarchy('parser.body')
      target_node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)
      target_node.add_child_node_hierarchy('parser.body')
      (@node - target_node).should be_nil
    end
  end

  context '#matching_child_node' do
    before :each do
      @node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)
    end

    it "should return matching child node" do
      match_node = JavaSource::PackageTreeNode.add('parser', @node, 'ast', 1)
      @node.new_matching_child_node(match_node).should_not be_nil
    end

    it "should return nil when matching child node" do
      match_node = JavaSource::PackageTreeNode.add('ast', @node, 'ast', 1)
      @node.new_matching_child_node(match_node).should be_nil
    end
  end

  context '#matches?' do
    before :each do
      @node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
    end

    it "should return true when matches name and level" do
      match_node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)
      @node.matches?(match_node).should be_true
    end

    it "should return false when name is not *" do
      match_node = JavaSource::PackageTreeNode.add('java', nil, 'parser.ast', 0)
      @node.matches?(match_node).should be_false
    end
  end

  context '#matches_level?' do
    before :each do
      @node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
    end

    it "should return true when name is *" do
      @node.matches_level?(0).should be_true
    end

    it "should return false when name is not *" do
      @node.matches_level?(1).should be_false
    end
  end

  context '#matches_name?' do
    before :each do
      @node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
    end

    it "should return true when name is *" do
      @node.matches_name?('japa').should be_true
    end

    it "should return false when name is not *" do
      @node.matches_name?('java').should be_false
    end
  end

  context '#matches_all_child_nodes??' do
    it "should return true when name is *" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '*', 0)
      node.matches_all_child_nodes?.should be_true
    end

    it "should return false when name is not *" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      node.matches_all_child_nodes?.should be_false
    end
  end

  context '#matches_all_nodes?' do
    it "should return true when name is *" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '*', 0)
      child_node = node.instance_variable_get('@child_nodes').first
      child_node.matches_all_nodes?.should be_true
    end

    it "should return false when name is not *" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '*', 0)
      node.matches_all_nodes?.should be_false
    end
  end

  context '#leaf_node?' do
    it "should return true when it has no child nodes" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      node.should be_leaf_node
    end

    it "should return false when it has child nodes" do
      node = JavaSource::PackageTreeNode.add('japa', nil, 'parser', 0)
      node.should_not be_leaf_node
    end
  end

  context '#find_package_node_by_name_and_level' do
    it "should return self when it matches both name and level" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      matching_node = node.find_package_node_by_name_and_level('japa', 0)
      matching_node.should_not be_nil
      matching_node.should == node
    end

    it "should return nil when the level is lower than itself" do
      node = JavaSource::PackageTreeNode.add('japa', nil, 'parser', 0)
      child_node = node.instance_variable_get('@child_nodes').first
      matching_node = child_node.find_package_node_by_name_and_level('japa', 0)
      matching_node.should be_nil
    end

    it "should return matching child node when the level is higher than itself" do
      node = JavaSource::PackageTreeNode.add('japa', nil, 'parser', 0)
      child_node = node.instance_variable_get('@child_nodes').first
      matching_node = node.find_package_node_by_name_and_level('parser', 1)
      matching_node.should_not be_nil
      matching_node.should == child_node
    end
  end

  context '#matches_by_name_and_level?' do
    it "should return true when name and level match" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      node.matches_by_name_and_level?('japa', 0).should be_true
    end

    it "should return false level doesn't match" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      node.matches_by_name_and_level?('japa', 1).should be_false
    end

    it "should return false level doesn't match" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      node.matches_by_name_and_level?('java', 0).should be_false
    end

    it "should return false when both name and level don't match" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      node.matches_by_name_and_level?('java', 1).should be_false
    end
  end

  context "#packages" do
    it "should return self name when no child nodes exist" do
      node = JavaSource::PackageTreeNode.add('japa', nil, '', 0)
      node.packages.should == ['japa']
    end

    it "should return app package names" do
      node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)
      node.add_child_node_hierarchy('parser.body')
      node.add_child_node_hierarchy('body')

      node.packages.should == ['japa.parser.ast', 'japa.parser.body', 'japa.body']
    end
  end

  context "#add_child_node_hierarchy" do
    it "should create a new node" do
      parent_node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)

      child_nodes = parent_node.instance_variable_get("@child_nodes")
      child_nodes.should_not be_empty
      child_nodes.size.should == 1
      existing_node = child_nodes.first
      existing_node.instance_variable_get("@name").should == 'parser'
      existing_node.instance_variable_get("@level").should == 1
      existing_node.instance_variable_get("@parent_node").should == parent_node

      parent_node.add_child_node_hierarchy("body")

      child_nodes = parent_node.instance_variable_get("@child_nodes")
      child_nodes.should_not be_empty
      child_nodes.size.should == 2
      child_nodes.last.instance_variable_get("@name").should == 'body'
      child_nodes.last.instance_variable_get("@level").should == 1
      child_nodes.last.instance_variable_get("@parent_node").should == parent_node

      child_nodes = child_nodes.last.instance_variable_get("@child_nodes")
      child_nodes.should be_empty
    end

    it "should update an existing child node" do
      parent_node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)

      child_nodes = parent_node.instance_variable_get("@child_nodes")
      child_nodes.should_not be_empty
      child_nodes.size.should == 1
      existing_node = child_nodes.first
      existing_node.instance_variable_get("@name").should == 'parser'
      existing_node.instance_variable_get("@level").should == 1
      existing_node.instance_variable_get("@parent_node").should == parent_node

      parent_node.add_child_node_hierarchy("parser.body")

      child_nodes = parent_node.instance_variable_get("@child_nodes")
      child_nodes.should_not be_empty
      child_nodes.size.should == 1
      child_nodes.first.should == existing_node

      parent_node = child_nodes.first
      child_nodes = child_nodes.first.instance_variable_get("@child_nodes")
      child_nodes.should_not be_empty
      child_nodes.size.should == 2
      child_nodes.last.instance_variable_get("@name").should == 'body'
      child_nodes.last.instance_variable_get("@level").should == 2
      child_nodes.last.instance_variable_get("@parent_node").should == parent_node

      child_nodes = child_nodes.last.instance_variable_get("@child_nodes")
      child_nodes.should be_empty
    end
  end

  context "#add" do
    it "should create a new node with child nodes" do
      parent_node = JavaSource::PackageTreeNode.add('japa', nil, 'parser.ast', 0)
      parent_node.should_not be_nil
      parent_node.instance_variable_get("@name").should == 'japa'
      parent_node.instance_variable_get("@level").should == 0
      parent_node.instance_variable_get("@parent_node").should be_nil

      child_nodes = parent_node.instance_variable_get("@child_nodes")
      child_nodes.should_not be_empty
      child_nodes.first.instance_variable_get("@name").should == 'parser'
      child_nodes.first.instance_variable_get("@level").should == 1
      child_nodes.first.instance_variable_get("@parent_node").should == parent_node

      parent_node = child_nodes.first
      child_nodes = child_nodes.first.instance_variable_get("@child_nodes")
      child_nodes.should_not be_empty
      child_nodes.first.instance_variable_get("@name").should == 'ast'
      child_nodes.first.instance_variable_get("@level").should == 2
      child_nodes.first.instance_variable_get("@parent_node").should == parent_node

      child_nodes = child_nodes.first.instance_variable_get("@child_nodes")
      child_nodes.should be_empty
    end
  end
end