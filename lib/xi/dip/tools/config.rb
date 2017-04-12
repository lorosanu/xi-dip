# encoding: utf-8


class Xi::DIP::Config
  @config = {}

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
