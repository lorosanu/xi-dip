# encoding: utf-8

require 'yaml'
require 'fileutils'
require 'uri'
require 'net/http'
require 'tempfile'
require 'tmpdir'
require 'securerandom'
require 'rubygems/command_manager'
require 'rubygems/package'
require 'rake/testtask'
require 'json'

# Ugly hack for the gem building tasks to work
# (since it's depending on the execution of git)
Dir.chdir(File.dirname(__FILE__))

MODULE = 'xi-image'.freeze
MODULE_PATH = 'xi_image'.freeze
GEM_REPOSITORY = 'https://gem.xilopix.net:443'.freeze
GEMINABOX_REPOSITORY = true

LIB_DIR = File.expand_path('lib', File.dirname(__FILE__))
BIN_DIR = File.expand_path('bin', File.dirname(__FILE__))
PKG_DIR = File.expand_path('pkg', File.dirname(__FILE__))
CONF_DIR = File.expand_path('conf', File.dirname(__FILE__))
DOC_DIR = File.expand_path('doc', File.dirname(__FILE__))

desc "Create an archive of the project's files"
task :archive => ['archive:clean'] do
  name = "#{MODULE}-#{version}"

  archive_src(false)

  Dir.mktmpdir("#{MODULE}-archive") do |dir|
    FileUtils.mkdir_p(File.join(dir, name))
    sh "tar rhvf #{name}.tar -C #{dir} #{name}"
  end
  sh "xz -f #{name}.tar"
end

namespace :archive do
  desc 'Create an archive of the sources'
  task :src do
    archive_src(true)
  end

  desc 'Clean the archive'
  task :clean do
    FileUtils.rm_f("#{MODULE}-#{version}.tar.xz")
  end
end

desc 'Build and publish all packages'
task :pkg => ['pkg:clean', 'pkg:build', 'pkg:publish']
namespace :pkg do
  desc 'Build package of a specified component (all if none specified)'
  task :build do |_t, _args|
    gem_build(MODULE)
  end

  desc 'Publish package of a specified component (all if none specified)'
  task :publish => [:build] do |_t, _args|
    geminabox_delete(MODULE) if GEMINABOX_REPOSITORY \
      and geminabox_exist?(MODULE)
    gem_push(MODULE)
  end

  if GEMINABOX_REPOSITORY
    desc 'Unpublish package of a specified component (all if none specified)'
    task :unpublish do |_t, _args|
      geminabox_delete(MODULE) if geminabox_exist?(MODULE)
    end
  end

  desc 'Clean package files'
  task :clean do
    FileUtils.rm_rf(PKG_DIR)
  end
end

desc 'Check the syntax of every files'
task :syntax => ['syntax:src', 'syntax:bin', 'syntax:gems', 'syntax:conf']
namespace :syntax do
  desc 'Check the syntax of source files'
  task :src do
    Dir[File.join(LIB_DIR, '**', '*.rb')].each do |f|
      sh "ruby -cw #{f}"
    end
  end

  desc 'Check the syntax of script files'
  task :bin do
    Dir[File.join(BIN_DIR, '*')].each do |f|
      sh "ruby -cw #{f}"
    end
  end

  desc 'Check the syntax of gem files'
  task :gems do
    Dir[File.join('**', '*.gemspec')].each do |f|
      sh "ruby -cw #{f}"
    end
  end

  desc 'Check the syntax of config files'
  task :conf do
    Dir[File.join(CONF_DIR, '**', '*.conf')].each do |f|
      sh "ruby -ryaml -e 'YAML.load(STDIN)' < #{f}"
    end
  end
end

namespace :version do
  desc 'Bump version of the application'
  task :bump => ['version:bump:minor']
  namespace :bump do
    desc 'Bump the patch version number'
    task :patch do
      version = version_read()
      version[2] += 1
      version_write(version)
    end

    desc 'Bump the minor version number'
    task :minor do
      version = version_read()
      version[1] += 1
      version_write(version)
    end

    desc 'Bump the major version number'
    task :major do
      version = version_read()
      version[0] += 1
      version_write(version)
    end
  end

  desc 'Set/Unset a tag on current version (development)'
  task :tag, [:name] do |_t, args|
    if args.name and !args.name.empty?
      version = version_read()
      version[3] = args.name.strip
      version_write(version)
    else
      version = version_read()
      version.delete_at(3)
      version_write(version)
    end
  end
end

def archive_src(compress=true)
  if compress
    sh "git archive -v --format=tar --prefix='#{MODULE}-#{version}/' HEAD | xz -c > #{MODULE}-#{version}.tar.xz"
  else
    sh "git archive -v --format=tar --prefix='#{MODULE}-#{version}/' --output #{MODULE}-#{version}.tar HEAD"
  end
end

def gem_name(comp)
  comp
end

def gem_pkg_file(comp, dir=nil)
  File.join(dir || PKG_DIR, "#{gem_name(comp)}-#{version}.gem")
end

def gem_spec_file(comp)
  "#{gem_name(comp)}.gemspec"
end

def gem_build(comp)
  raise unless cmd = Gem::CommandManager.instance[:build]
  cmd.handle_options([gem_spec_file(comp)])
  cmd.execute
  FileUtils.mkdir_p(PKG_DIR) unless File.exist?(PKG_DIR)
  FileUtils.mv(gem_pkg_file(comp, Dir.pwd), gem_pkg_file(comp))
end

def gem_push(comp)
  file = gem_pkg_file(comp)
  fail "file not found '#{file}', please build first" unless File.exist?(file)

  begin
    tmpfile = Tempfile.new("#{MODULE}-gemrc")
    tmpfile.write(
      {
        :sources => [GEM_REPOSITORY],
        :disable_default_gem_server => true,
      }.to_yaml
    )
    tmpfile.close

    Gem.configuration.rubygems_api_key = ''
    raise unless cmd = Gem::CommandManager.instance[:push]
    cmd.handle_options([
      '--config-file', tmpfile.path,
      '--host', GEM_REPOSITORY,
      gem_pkg_file(comp)
    ])
    cmd.execute
  ensure
    tmpfile.unlink
  end
end

def geminabox_http_path(comp)
  File.join('/', 'gems', File.basename(gem_pkg_file(comp)))
end

def geminabox_exist?(comp)
  uri = URI(GEM_REPOSITORY)
  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true if uri.scheme == 'https'
  http.start
  resp = http.head(geminabox_http_path(comp))
  if resp.is_a?(Net::HTTPSuccess)
    true
  else
    false
  end
end

def geminabox_delete(comp)
  uri = URI(GEM_REPOSITORY)
  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true if uri.scheme == 'https'
  http.start
  resp = http.delete(geminabox_http_path(comp))
  fail <<-EOS if !resp.is_a?(Net::HTTPSuccess) and !resp.is_a?(Net::HTTPRedirection) and !resp.is_a?(Net::HTTPBadGateway) # BadGateway -> geminabox "bug"
    HTTP/DELETE failed on #{File.join(uri.to_s, geminabox_http_path(comp))}
    ##{resp.code}: #{resp.message} #{resp.to_hash}
  EOS
  puts "Removed #{File.basename(geminabox_http_path(comp))}"
end

def version_file
  File.join(File.dirname(__FILE__), 'lib', MODULE_PATH, 'version.rb')
end

def version
  version_read.join('.')
end

def version_read
  content = File.read(version_file)
  if content =~ /(\d+)\.(\d+)\.(\d+)(?:\.([\w\.-]+))?/
    ret = Regexp.last_match.to_a[1..3].map{|v| v.to_i }
    ret[3] = Regexp.last_match(4) if Regexp.last_match(4)
    ret
  else
    abort 'Invalid version file'
  end
end

def version_write(version)
  File.open(version_file, 'r') do |file|
    content = file.read
    file.reopen(version_file, 'w')
    file.write(content.gsub(/\d+\.\d+\.\d+(?:\.([\w\.-]+))?/, version.join('.')))
  end
end

def tar(*files, writer:nil)
  tw = writer || Gem::Package::TarWriter.new(StringIO.new)

  files.each do |file|
    if file.is_a?(String)
      path = file.gsub(/^#{File.expand_path(File.dirname(__FILE__))}\/?/, '')
    elsif file.is_a?(Hash)
      file, path = file.first
    end
    mode = File.stat(file).mode

    if File.directory?(file)
      tw.mkdir(path, mode)
      tar(*Dir[File.join(file, '*')], writer: tw)
    else
      tw.add_file(path, mode) do |tf|
        File.open(file, 'rb') {|f| tf.write f.read }
      end
    end
  end

  unless writer
    tw.close
    out = tw.instance_variable_get(:@io)
    out.rewind
    out
  end
end
