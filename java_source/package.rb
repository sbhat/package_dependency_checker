module JavaSource
  class Package
    def initialize name
      @name = name
      @scopes = name.split('.')
      @is_asterics = (@scopes.last == "*")

      @scope = @is_asterics ? @scopes[0..(@scopes.size-2)].join('.') : name
    end

    def accepts? package_name
      if @is_asterics
        return !(/^#{@scope}*/ =~ package_name).nil?
      else
        return package_name == @scope
      end
    end
  end
end