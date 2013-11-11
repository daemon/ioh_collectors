require 'logger'
require 'ostruct'
require 'yaml'

module App
  class << self
    attr_accessor :logger, :config

    def root
      @root ||= File.expand_path('..', File.dirname(__FILE__))
    end

    def logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def config
      @config ||= Config.new
    end
  end

  class Config < OpenStruct

    def load(file)
      YAML.load_file(file).each_pair do |k, v|
        k = k.to_sym
        @table[k] = v
        new_ostruct_member(k)
      end
    end

  end

end
