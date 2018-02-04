module Cinnabar
  require 'json'
  
  # Config object.
  module Config
    @config = JSON.parse(File.read('.\data\config.json'), symbolize_names: true)
    
    @config.keys.each do |key|
      self.class.send(:define_method, key) do
        @config[key]
      end
    end
  end
end