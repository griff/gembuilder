#!/usr/bin/env ruby

require "rbconfig"
require "rubygems"
require "tmpdir"
require "find"
require "fileutils"
Gem.manage_gems


class GemBuilder
  VERSION = '1.1.0'
  OBJEXT = ".#{Config::CONFIG["OBJEXT"]}"

  def initialize(gem)
    @gem_name = gem
    @installer = Gem::Installer.new(@gem_name)
    @format = Gem::Format.from_file_by_path(@gem_name)
  end

  def tmpdir
    @tmpdir ||= File.join(Dir.tmpdir, "gembuilder")
  end

  def installer
    @installer ||= Gem::Installer.new(@gem_name)
  end
  
  def format
    @format ||= Gem::Format.from_file_by_path(@gem_name)
  end
  
  def spec
    @spec ||= format.spec
  end
  
  def unpack_gem
    FileUtils.rm_r(tmpdir) rescue nil
    FileUtils.mkdir_p(tmpdir) rescue nil
    installer.unpack(tmpdir)
  end

  def build_extensions
    installer.build_extensions(tmpdir, format.spec)
  end
  
  def fix_gemspec(conservative = false)
    files = []
    Find.find(tmpdir) do |fname|
      next if fname == tmpdir
      next if !conservative && File.extname(fname) == OBJEXT 
      files << fname.sub(Regexp.quote(tmpdir + "/"), '')
    end

    spec.extensions = []
    spec.files += (files - format.spec.files)
    spec.platform = Config::CONFIG['arch'].sub(/[\.0-9]*$/, '')
  end
  
  def build_gem
    start_dir = Dir.pwd
    Dir.chdir(tmpdir) do
      gb = Gem::Builder.new(spec)
      gb.build
      FileUtils.mv Dir.glob("*.gem"), start_dir
    end
  end
  
  def cleanup
    FileUtils.rm_rf(tmpdir)
  end

end

