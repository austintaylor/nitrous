require File.dirname(__FILE__) + '/../test_helper'
AssertionFailedError = Nitrous::AssertionFailedError
class TestTest < Nitrous::Test
  test "setup got called" do
    assert! @setup_called
  end
  
  test "teardown got called" do
    assert! @teardown_called
  end
  
  def setup
    @setup_called = true
  end
  
  def teardown
    @teardown_called = true
  end
end
