# encoding: utf-8

require 'log4r'
require 'log4r/yamlconfigurator'

Log4r::YamlConfigurator.load_yaml_file(File.expand_path('./log4r.yml',
  File.dirname(__FILE__)))

module Xi
  module DIP
    Logger = Log4r::Logger['xi_dip']

    module Config
      @config = {}

      def self.load(config)
        @config.update(config)
      end

      def self.load_yaml(path)
        @config.update(YAML.load_file(path))
      end

      def self.get(namespace, default = nil)
        config = @config
        namespace.split('/').each do |ns|
          return default unless config.is_a?(Hash) && config.key?(ns)
          config = config[ns]
        end
        config
      end

      def self.set(namespace, value)
        config = @config
        namespace = namespace.split('/')
        last = namespace.pop
        namespace.each do |ns|
          config[ns] = {} unless config.key? ns
          config = config[ns]
        end
        config[last] = value
      end
    end
  end
end

require 'xi/dip/image'
