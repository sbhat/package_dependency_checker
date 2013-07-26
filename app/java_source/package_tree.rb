require 'app/java_source/package_tree_node.rb'

module JavaSource
  class PackageTree
    def initialize root_package_nodes = []
      @root_package_nodes = root_package_nodes
    end

    def self.create_by package_name
      package_names = package_name.split('.')
      return self.new if package_names.empty?

      root_package = package_names.first
      child_packages = (package_names[1..-1] || [])
      new_root_package_node = JavaSource::PackageTreeNode.add(root_package, nil, child_packages, 0)

      self.new([new_root_package_node])
    end

    def add package_name
      package_names = package_name.split('.')
      unless package_names.empty?
        if matching_root_package_node = find_package_node_by_name_and_level(package_names.first, 0)
          matching_root_package_node.add_child_nodes(package_names[1..-1] || [])
        else
          new_root_package_node = JavaSource::PackageTreeNode.add(package_names.first, nil, (package_names[1..-1] || []), 0)
          @root_package_nodes << new_root_package_node unless new_root_package_node.nil?
        end
      end
    end

    def find_package_node_by_name_and_level package_name, level = 0
      matching_package_node = nil
      @root_package_nodes.each do |root_package_node|
        matching_package_node = root_package_node.find_package_node_by_name_and_level(package_name, level)
        break if !(matching_package_node).nil?
      end
      matching_package_node
    end

    def find_root_package_node package_node
      @root_package_nodes.detect{|root_package_node| root_package_node.matches?(package_node)}
    end

    def - (target_package_tree)
      new_root_package_nodes = []
      @root_package_nodes.each do |root_package_node|
        matching_root_package_node = target_package_tree.find_root_package_node(root_package_node)
        new_root_package_node = (matching_root_package_node.nil? ? root_package_node : (root_package_node - matching_root_package_node))
        new_root_package_nodes << new_root_package_node if new_root_package_node
      end

      self.class.new(new_root_package_nodes)
    end

    def packages
      @root_package_nodes.map{|root_package_node| root_package_node.packages}.flatten
    end
  end
end