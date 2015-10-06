require 'log4r'
require 'log4r/yamlconfigurator'

Log4r::YamlConfigurator.load_yaml_file(File.expand_path('./log4r.yml',
                                                        File.dirname(__FILE__)))

module XiImage
  Logger = Log4r::Logger['xi_nlp']
end
