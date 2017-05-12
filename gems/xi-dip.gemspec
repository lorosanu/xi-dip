# coding: utf-8

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'xi/dip/version'

Gem::Specification.new do |spec|
  spec.name             = 'xi-dip'
  spec.version          = Xi::DIP::VERSION
  spec.authors          = ['Paul Bédaride']
  spec.email            = ['paul.bedaride@xilopix.com']
  spec.summary          = %q{Xilopix Digital Image Processing library}
  spec.description      = %q{Analysing images}

  spec.files            = `git ls-files -z lib/`.split("\x0")
  spec.extra_rdoc_files = `git ls-files -z conf/`.split("\x0") + %w{README}
  spec.require_paths    = ['lib']
  spec.bindir           = 'bin'
  spec.executables      = %w[analyze_image extract_color create_dataset
                             detect_color folder_analyze_detect]

  spec.add_runtime_dependency 'log4r', '~> 1.1', '>= 1.1.10'
  spec.add_runtime_dependency 'rmagick', '~> 2', '>= 2.15.0'
  spec.add_runtime_dependency 'exifr', '~> 1', '>= 1.2.0'
  spec.add_runtime_dependency 'xi-ml', '~> 0.5', '>= 0.5.0'

  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'xi-rake', '~> 0.1', '>= 0.1.0'

  spec.required_ruby_version = '>= 1.9.1'
end
