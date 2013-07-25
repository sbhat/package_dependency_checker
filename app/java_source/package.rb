module JavaSource
  class Package
    REGEX_MATCH_NAME_ENDING_WITH_ASTERICS = /(.\*)$/

    def initialize name
      @match_child_packages = !(name =~ REGEX_MATCH_NAME_ENDING_WITH_ASTERICS).nil?
      @name = @match_child_packages ? name.gsub('.*', '') : name
      @regex_match_parent_and_child_packages = /^#{@name}(.([A-Za-z0-9])*)*/
    end

    def matches? source_package_name
      @match_child_packages ? parent_of?(source_package_name)  : matches_exactly?(source_package_name)
    end

    private

    def matches_exactly? source_package_name
      source_package_name == @name
    end

    def parent_of? source_package_name
      !(source_package_name =~ @regex_match_parent_and_child_packages).nil?
    end
  end
end