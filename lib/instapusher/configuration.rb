require 'yaml'

module Instapusher
  module Configuration
    extend self

    @_settings = {}
    attr_reader :_settings

    def load(filename=nil)
      filename ||= File.join(ENV['HOME'], '.instapusher')

      unless File.exist? filename
        File.new(filename, File::CREAT|File::TRUNC|File::RDWR, 0644).close
      end

      @_settings = YAML::load_file(filename) || {}
    end

    def method_missing(name, *args, &block)
      @_settings[name.to_s]
    end
  end
end
