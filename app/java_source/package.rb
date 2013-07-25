module JavaSource
  class Package
    def initialize name
      @name = name
      @scopes = name.split('.')
      @is_asterics = (@scopes.last == "*")

      @scope = @is_asterics ? @scopes[0..(@scopes.size-2)].join('.') : name
    end

    def accepts? source_package_name
      if @is_asterics
        return !(/^#{@scope}*/ =~ source_package_name).nil?
      else
        return source_package_name == @scope
      end
    end
  end
end