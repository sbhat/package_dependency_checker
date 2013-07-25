require 'app/java_source/package_tree_node.rb'

class JavaSource::PackageTree
  def initialize root_nodes = []
    @root_nodes = root_nodes
  end

  def find_node_by_name_and_level node_name, level = 0
    matching_node = nil
    @root_nodes.each do |root_node|
      matching_node = root_node.find_by_name_and_level(node_name, level)
      break if !(matching_node).nil?
    end
    matching_node
  end

  def matching_root_node match_node
    @root_nodes.detect{|node| node.matches?(match_node)}
  end

  def - (target_tree)
    root_nodes = []
    @root_nodes.each do |root_node|
      target_root_node = target_tree.matching_root_node(root_node)
      if target_root_node.nil?
        root_nodes << root_node
      else
        new_node =  root_node - target_root_node
        root_nodes << new_node if new_node
      end
    end

    self.class.new(root_nodes)
  end

  def self.add package_name
    package_names = package_name.split('.')
    new_root_node = (package_names.empty? ? nil : JavaSource::PackageTreeNode.add(package_names.first, nil, (package_names[1..-1] || []), 0))
    self.new([new_root_node].compact)
  end

  def add package_name
    package_names = package_name.split('.')
    unless package_names.empty?
      matching_root_node = find_node_by_name_and_level(package_names.first, 0)
      if matching_root_node
        matching_root_node.add_child_nodes(package_names[1..-1] || [])
      else
        new_root_node = JavaSource::PackageTreeNode.add(package_names.first, nil, (package_names[1..-1] || []), 0)
        @root_nodes << new_root_node unless new_root_node.nil?
      end
    end
  end

  def to_a
    @root_nodes.map do |root_node|
      root_node.to_a
    end.flatten
  end
end