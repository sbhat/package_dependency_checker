require 'app/java_source/package_tree_node.rb'

module JavaSource
  class PackageTree
    def initialize root_package_nodes = []
      @root_package_nodes = root_package_nodes
    end

    def self.create_by package_name
      new_root_package_nodes = []
      new_root_package_node = create_new_root_package_node package_name
      new_root_package_nodes << new_root_package_node if new_root_package_node
      self.new(new_root_package_nodes)
    end

    def self.create_new_root_package_node package_name
      package_names = package_name.split('.')
      return nil if package_names.empty?

      root_package = package_names.first
      child_packages = (package_names[1..-1] || [])
      JavaSource::PackageTreeNode.add(root_package, nil, child_packages, 0)
    end

    def add package_name
      package_names = package_name.split('.')
      unless package_names.empty?
        if matching_root_package_node = find_root_package_node_by_name(package_names.first)
          matching_root_package_node.add_child_nodes(package_names[1..-1] || [])
        else
          new_root_package_node = JavaSource::PackageTreeNode.add(package_names.first, nil, (package_names[1..-1] || []), 0)
          @root_package_nodes << new_root_package_node unless new_root_package_node.nil?
        end
      end
    end

    def new_root_package_node_for_unsupported_packages_in package_node
      matching_root_package_node = find_root_package_node(package_node)
      (matching_root_package_node.nil? ? package_node.clone : (package_node - matching_root_package_node))
    end

    def - (target_package_tree)
      new_root_package_nodes = []
      @root_package_nodes.each do |root_package_node|
        new_root_package_node = target_package_tree.new_root_package_node_for_unsupported_packages_in(root_package_node)
        new_root_package_nodes << new_root_package_node if new_root_package_node
      end

      self.class.new(new_root_package_nodes)
    end

    def packages
      @root_package_nodes.map{|root_package_node| root_package_node.packages}.flatten
    end

    private

    def find_root_package_node_by_name package_name
      @root_package_nodes.detect{|root_package_node| root_package_node.matches_name?(package_name)}
    end

    def find_root_package_node package_node
      @root_package_nodes.detect{|root_package_node| root_package_node.matches?(package_node)}
    end
  end
end