#!/usr/bin/env ruby

require "rbconfig"
require "rubygems"
require "tmpdir"
require "find"
require "fileutils"
require "rubygems/installer"
require "gembuilder/version"

class GemBuilderLib
  OBJEXT = ".#{Config::CONFIG["OBJEXT"]}"

  # Helper that will do it all
  def self.[](gemfile,conservative=false)
    gem_builder = GemBuilderLib.new(gemfile)
    gem_builder.do_all(conservative)
  end
  
  def self.tmpdir(newtmpdir=nil)
    @tmpdir ||= File.join(Dir.tmpdir, "gembuilder")
    @tmpdir = newtmpdir if newtmpdir
    @tmpdir
  end
  
  def self.platform
    # Use Gem::Platform to clean up names under darwin
    @platform ||= Gem::Platform.new(Config::CONFIG['arch']).to_s
  end
  
  def initialize(gemfile)
    @gem_name = gemfile
    @installer = Gem::Installer.new(@gem_name)
    @format = Gem::Format.from_file_by_path(@gem_name)
  end
  
  def do_all(conservative=false)
    self.unpack_gem
    self.build_extensions
    self.fix_gemspec(conservative)
    self.build_gem
    self.cleanup
  end
  
  def output_dir
    @output_dir ||= File.dirname(@gem_name)
  end
  
  def output_dir=(newval)
    @output_dir = newval
  end

  def tmpdir
    File.join(self.class.tmpdir, File.basename(@gem_name))
  end

  def installer
    @installer ||= Gem::Installer.new(@gem_name)
  end
  
  def format
    @format ||= Gem::Format.from_file_by_path(@gem_name)
  end
  
  def spec
    @spec ||= begin 
      spe = eval(format.spec.to_ruby)
      spe.cert_chain = [] unless spe.cert_chain
      spe
    end
  end
  
  def pure?
    spec.extensions.size == 0
  end
  
  def unpack_gem
    FileUtils.rm_r(tmpdir) rescue nil
    FileUtils.mkdir_p(tmpdir) rescue nil
    installer.unpack(tmpdir)
  end

  def build_extensions
    installer.build_extensions
  end

  def platform
    self.class.platform
  end
  
  def output
    "#{spec.name}-#{spec.version}-#{platform}.gem"
  end
  
  def output_file
    File.join(output_dir, output)
  end
  
  def fix_gemspec(conservative = false)
    files = []
    Find.find(tmpdir) do |fname|
      next if fname == tmpdir
      next if !conservative && File.extname(fname) == OBJEXT 
      files << fname.sub(Regexp.new(Regexp.quote(tmpdir + "/")), '')
    end

    spec.extensions = []
    spec.files += (files - format.spec.files)
    spec.platform = platform
  end
  
  def build_gem
    start_dir = Dir.pwd
    Dir.chdir(tmpdir) do
      gb = Gem::Builder.new(spec)
      gb.build
      FileUtils.mv self.output, File.expand_path(self.output_dir, start_dir)
    end
  end
  
  def cleanup
    FileUtils.rm_rf(tmpdir)
  end

end

