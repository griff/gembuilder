require "test/unit"
require "gembuilderlib"

class TestFastthreadBug < Test::Unit::TestCase
  GEMNAME = 'fastthread-1.0.7'

  def setup
    # find our test gem file.
    # Note the nasty reliance on an external file
    # and our eventual use of your file system 
    # slowing the tests
    #
    @olddir = Dir.pwd
    Dir.chdir 'test/gems'
    dir = File.expand_path(File.join('..', '..', 'tmp'))
    Dir.mkdir(dir) unless File.exists?(dir)
    GemBuilderLib.tmpdir(dir)
    @gb = GemBuilderLib.new("#{GEMNAME}.gem")
  end

  def teardown
    # how craptacular is this -- I am using the thing I am 
    # testing to cleanup -- somebody save me from my own
    # insanity
    @gb.cleanup
    FileUtils.rm(@gb.output_file) if File.exists?(@gb.output_file)
    Dir.chdir @olddir
  end

  def assert_file_exists(fname, msg = "The file #{fname} should exist and does not.")
    assert(File.exists?(fname), msg)
  end
  
  def test_class_doit_all_method
    GemBuilderLib["#{GEMNAME}.gem"]
    puts @gb.spec.cache_file
    assert_file_exists(@gb.output_file)
    # not sure how to verify that the temp directory is properly cleaned up
    # without adding some odd support for returning the temp directory name
    # that should already be deleted at this point 
  end
  
end