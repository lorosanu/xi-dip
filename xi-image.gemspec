# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xi_image/version'

Gem::Specification.new do |spec|
  spec.name          = "xi-image"
  spec.version       = XiImage::VERSION
  spec.authors       = ["Paul Bédaride"]
  spec.email         = ["paul.bedaride@xilopix.com"]
  spec.summary       = %q{Xilopix image processing library}
  spec.description   = %q{Analysing images}

  spec.files         = `git ls-files -z lib/ data/`.split("\x0")
  spec.extra_rdoc_files = `git ls-files -z conf/`.split("\x0") \
    + %w{README}
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rmagick", "~> 2", ">= 2.15.0"
  spec.add_runtime_dependency "exifr", "~> 1", ">= 1.2.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
