class JavaSource::PackageTreeNode
  attr_writer :parent_node

  def initialize name, parent_node = nil, child_nodes = [], level = 0
    @name = name
    @parent_node = parent_node
    @child_nodes = child_nodes
    @child_nodes.each do |child_node|
      child_node.parent_node = self
    end
    @level = level
  end

  def self.add name, parent_node, child_node_names, level
    self.new(name, parent_node, [], level).tap do |new_node|
      new_node.add_child_nodes(child_node_names) unless child_node_names.empty?
    end
  end

  def add_child_nodes child_node_names
    unless child_node_names.empty?
      if child_node = self.find_by_name_and_level(child_node_names.first, @level+1)
        child_node.add_child_nodes(child_node_names[1..-1] || [])
      else
        new_child_node = self.class.add(child_node_names.first, @parent_node, (child_node_names[1..-1] || []), @level+1)
        @child_nodes << new_child_node unless new_child_node.nil?
      end
    end
  end

  def to_a
    if @child_nodes.empty?
      [@name]
    else
      @child_nodes.map{|child_node| child_node.to_a}.flatten.map{|child_name| "#{@name}.#{child_name}"}
    end
  end

  def is? name, level
    @name == name && @level == level
  end

  def find_by_name_and_level name, level
    return self if iam?(name, level)
    if level > @level
      matching_node = nil
      @child_nodes.each do |child_node|
        matching_node = child_node.find_by_name_and_level(name, level)
        break if !matching_node.nil?
      end
      return matching_node
    end
    return nil
  end

  def - (target_package_node)
    if matches_all?(target_package_node)
      return nil
    elsif matches_leaf_node?(target_package_node)
      return (has_non_leaf_child_nodes? ? clone_with_non_leaf_child_nodes : nil)
    elsif matches_exactly?(target_package_node)
      return nil
    elsif matches?(target_package_node)
      return clone_with(left_join_of_child_nodes(package_tree_node))
    else
      return self
    end
  end

  def leaf_node?
    @child_nodes.empty?
  end

  def matches_all_nodes?
    @name == '*'
  end

  def matches_name? name
    @name == name
  end

  def matches_level? level
    @level == level
  end

  def matches_all_child_nodes?
    @child_nodes.size == 1 && @child_nodes.first.matches_all_nodes?
  end

  def matches? package_tree_node
    package_tree_node.matches_name?(@name) && package_tree_node.matches_level?(@level)
  end

  def matching_child_node match_node
    @child_nodes.detect{|node| node.matches?(match_node)}
  end

  private

  alias :iam? :is?

  def matches_all? package_tree_node
    matches?(package_tree_node) && package_tree_node.matches_all_child_nodes?
  end

  def matches_exactly? package_tree_node
    matches?(package_tree_node) && left_join_of_child_nodes(package_tree_node).empty?
  end

  def matches_leaf_node? package_tree_node
    matches?(package_tree_node) && package_tree_node.leaf_node?
  end

  def clone_with_non_leaf_child_nodes
    self.class.new(@name, @parent_node, non_leaf_child_nodes, @level)
  end

  def clone_with child_nodes
    self.class.new(@name, @parent_node, child_nodes, @level)
  end

  def left_join_of_child_nodes package_tree_node
    child_nodes = []
    @child_nodes.each do |child_node|
      matching_target_child_node = package_tree_node.matching_child_node(child_node)
      if matching_target_child_node.nil?
        child_nodes << child_node
      else
        new_node =  child_node - matching_target_child_node
        child_nodes << new_node if new_node
      end
    end
    child_nodes
  end

  def leaf_child_nodes
    @child_nodes.select{|node| node.leaf_node?}
  end

  def has_leaf_child_nodes?
    !@leaf_child_nodes.empty?
  end

  def non_leaf_child_nodes
    @child_nodes.select{|node| !node.leaf_node?}
  end

  def has_non_leaf_child_nodes?
    !@non_leaf_child_nodes.empty?
  end
end