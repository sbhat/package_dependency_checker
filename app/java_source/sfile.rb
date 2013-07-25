require 'java'

require "lib/ruby/java_lib.rb"
require "lib/ruby/java_io.rb"

module JavaSource
  class SFile
    attr_reader :name

    def initialize file_path
      @jcompilation_unit = JavaLib::JavaParser.parse(JavaIO::FileInputStream.new(file_path))
      @name = File.basename(file_path)
    end

    def source_package
      @jcompilation_unit.package.name.to_s
    end

    def import_declarations
      (@jcompilation_unit.imports || []).to_a
    end
  end
end