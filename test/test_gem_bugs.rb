#encoding: utf-8
require "test/unit"
require "gembuilderlib"

class TestUTF8SpecBug < Test::Unit::TestCase
  GEMNAME = 'backports-2.2.1'

  def setup
    # find our test gem file.
    # Note the nasty reliance on an external file
    # and our eventual use of your file system 
    # slowing the tests
    #
    @gemsdir = File.expand_path('../gems', __FILE__)
    @workdir = File.expand_path('../../tmp', __FILE__)
    Dir.mkdir(@workdir) unless File.exists?(@workdir)
    GemBuilderLib.tmpdir(@workdir)
  end

  def teardown
    #FileUtils.rm_rf(@workdir)
    Dir.glob("#{@gemsdir}/*-#{GemBuilderLib.platform}.gem").each{|f| FileUtils.rm(f)}
  end

  def assert_file_exists(fname, msg = "The file #{fname} should exist and does not.")
    assert(File.exists?(fname), msg)
  end
  
  # Test with a spec that contains utf-8 characters
  def test_utf8_spec
    # Temporarily force default external encoding to utf-8 so that the gem spec is read correctly
    # 
    if RUBY_VERSION > '1.9' then
      old_enc = Encoding.default_external
      Encoding.default_external="UTF-8"
    end
    
    gb = GemBuilderLib.new(File.join(@gemsdir, "backports-2.2.1.gem"))
    gb.do_all
    assert_file_exists(gb.output_file)
    
    Encoding.default_external = old_enc if RUBY_VERSION > '1.9'
  end
  
  def test_fastthread
    gb = GemBuilderLib.new(File.join(@gemsdir, "fastthread-1.0.7.gem"))
    gb.do_all
    assert_file_exists(gb.output_file)
  end
  
  def test_missing_authors
    gb = GemBuilderLib.new(File.join(@gemsdir, "diff-lcs-1.1.2.gem"))
    gb.do_all
    assert_file_exists(gb.output_file)
  end
  
end