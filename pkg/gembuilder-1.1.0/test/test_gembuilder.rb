require "test/unit"

require "gembuilder"

class TestGembuilder < Test::Unit::TestCase
  def setup
    puts "In #{Dir.pwd}"
    
  end
  
  def test_case_name
    assert(true, "Failure message.")
  end
end