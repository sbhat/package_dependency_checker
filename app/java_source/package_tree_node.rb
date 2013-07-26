module JavaSource
  class PackageTreeNode
    attr_writer :parent_node

    def initialize name, parent_node = nil, child_nodes = [], level = 0
      @name = name
      @parent_node = parent_node
      @child_nodes = child_nodes
      @child_nodes.each do |child_node|
        child_node.set_parent self
      end
      @level = level
    end

    def self.add name, parent_node, child_node_names, level
      self.new(name, parent_node, [], level).tap do |new_node|
        child_node_names = child_node_names.split('.') unless child_node_names.is_a?(Array)
        new_node.add_child_nodes(child_node_names) unless child_node_names.empty?
      end
    end

    def set_parent parent_node
      if parent_node
        @parent_node = parent_node
      else
        raise "Already belongs to a parent package!!"
      end
    end

    def add_child_nodes child_node_names
      child_node_names = child_node_names.split('.') unless child_node_names.is_a?(Array)
      unless child_node_names.empty?
        if child_node = self.find_package_node_by_name_and_level(child_node_names.first, @level+1)
          child_node.add_child_nodes(child_node_names[1..-1] || [])
        else
          new_child_node = self.class.add(child_node_names.first, self, (child_node_names[1..-1] || []), @level+1)
          @child_nodes << new_child_node unless new_child_node.nil?
        end
      end
    end

    def packages
      if @child_nodes.empty?
        [@name]
      else
        @child_nodes.map{|child_node| child_node.packages}.flatten.map{|child_name| "#{@name}.#{child_name}"}
      end
    end

    def matches_by_name_and_level? name, level
      @name == name && @level == level
    end

    def find_package_node_by_name_and_level name, level
      return self if matches_by_name_and_level?(name, level)
      if level > @level
        matching_node = nil
        @child_nodes.each do |child_node|
          matching_node = child_node.find_package_node_by_name_and_level(name, level)
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
        return clone_with(left_join_of_child_nodes(target_package_node))
      else
        return clone
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

    def new_matching_child_node match_node
      matching_child_node = @child_nodes.detect{|node| node.matches?(match_node)}
      matching_child_node.nil? ? nil : matching_child_node.clone
    end

    def clone
      self.class.new(@name, @parent_node, @child_nodes.map{|child_node| child_node.clone}, @level)
    end

    private

    def add_child_node name, child_node_names
      self.class.add(name, self, child_node_names, @level + 1)
    end

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
      non_leaf_child_nodes.map!{|node| node.clone}
      self.class.new(@name, @parent_node, non_leaf_child_nodes, @level)
    end

    def clone_with child_nodes
      self.class.new(@name, @parent_node, child_nodes, @level)
    end

    def left_join_of_child_nodes package_tree_node
      child_nodes = []
      @child_nodes.each do |child_node|
        matching_target_child_node = package_tree_node.new_matching_child_node(child_node)
        if matching_target_child_node.nil?
          child_nodes << child_node.clone
        else
          new_node =  child_node - matching_target_child_node
          child_nodes << new_node if new_node
        end
      end
      child_nodes
    end

    def non_leaf_child_nodes
      @child_nodes.select{|node| !node.leaf_node?} || []
    end

    def has_non_leaf_child_nodes?
      !non_leaf_child_nodes.empty?
    end
  end
end
