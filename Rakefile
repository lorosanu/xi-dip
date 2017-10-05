# encoding: utf-8

require 'xi/rake'

# Constants
MODULE = 'dip'.freeze
MODULE_PREFIX = 'xi'.freeze
MODULE_PATH = "#{MODULE_PREFIX}/#{MODULE}".freeze
MODULE_NAME = "#{MODULE_PREFIX}-#{MODULE}".freeze

# Versioning
Xi::Rake::Task::Version.new(MODULE_PATH)

# Doc & Packaging
Xi::Rake::Task::Doc.new(MODULE_PATH, MODULE_NAME,
  yard_opts: ['--markup', 'markdown'])
Xi::Rake::Task::Archive.new(MODULE_PATH, MODULE_NAME)
Xi::Rake::Task::Package.new(MODULE_PATH, MODULE_NAME)

# Syntax
Xi::Rake::Task::Syntax.new()
Xi::Rake::Task::Lint::Ruby.new()

# Tests
desc 'Run tests'
task :test => ['test:spec', 'test:unit', 'test:integration']
Xi::Rake::Task::Test::Spec.new()
Xi::Rake::Task::Test::Unit.new()
Xi::Rake::Task::Test::Integration.new()
