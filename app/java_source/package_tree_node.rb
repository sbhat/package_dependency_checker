module JavaSource
  class PackageTreeNode
    attr_writer :parent_node

    def initialize name, parent_node = nil, child_nodes = [], level = 0
      @name = name
      @parent_node = parent_node
      @child_nodes = ((name == '*') ? [] : child_nodes)
      @child_nodes.each{|child_node| child_node.set_parent self }
      @level = level
    end

    def self.add name, parent_node, child_node_hierarchy, level
      new(name, parent_node, [], level).tap do |new_node|
        child_node_hierarchy = child_node_hierarchy.split('.') unless child_node_hierarchy.is_a?(Array)
        new_node.add_child_node_hierarchy(child_node_hierarchy) unless child_node_hierarchy.empty?
      end
    end

    def set_parent parent_node
      if parent_node
        @parent_node = parent_node
      else
        raise "Already belongs to a parent package!!"
      end
    end

    def add_child_node_hierarchy child_node_hierarchy
      child_node_hierarchy = child_node_hierarchy.split('.') unless child_node_hierarchy.is_a?(Array)
      unless child_node_hierarchy.empty?
        if child_node = self.find_package_node_by_name_and_level(child_node_hierarchy.first, @level+1)
          child_node.add_child_node_hierarchy(child_node_hierarchy[1..-1] || [])
        else
          new_child_node = self.class.add(child_node_hierarchy.first, self, (child_node_hierarchy[1..-1] || []), @level+1)
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
      if matches?(target_package_node)
        child_nodes =  left_join_of_child_nodes(target_package_node)
        return child_nodes.empty? ? nil: clone_with(child_nodes)
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

    def matching_child_node match_node
      matching_child_node = @child_nodes.detect{|node| node.matches?(match_node)}
      matching_child_node.nil? ? nil : matching_child_node
    end

    def clone
      self.class.new(@name, @parent_node, @child_nodes.map{|child_node| child_node.clone}, @level)
    end

    private

    def add_child_node name, child_node_hierarchy
      self.class.add(name, self, child_node_hierarchy, @level + 1)
    end

    def clone_with child_nodes
      self.class.new(@name, @parent_node, child_nodes, @level)
    end

    def left_join_of_child_nodes package_tree_node
      return [] if package_tree_node.matches_all_child_nodes?
      return non_leaf_child_nodes.map{|node| node.clone} if package_tree_node.leaf_node?
      [].tap do |child_nodes|
        @child_nodes.each do |child_node|
          matching_target_node = package_tree_node.matching_child_node(child_node)
          if matching_target_node.nil?
            child_nodes << child_node.clone
          else
            new_child_node = child_node - matching_target_node
            child_nodes << new_child_node if new_child_node
          end
        end
      end
    end

    def non_leaf_child_nodes
      @child_nodes.select{|node| !node.leaf_node?} || []
    end

    def has_non_leaf_child_nodes?
      !non_leaf_child_nodes.empty?
    end
  end
end
