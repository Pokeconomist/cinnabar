module Cinnabar
  # Config object
  module Config
    require 'json'

    @config = JSON.parse(File.read('.\data\config.json'), symbolize_names: true)

    @config.keys.each do |key|
      self.class.send(:define_method, key) do
        @config[key]
      end
    end
  end
end
