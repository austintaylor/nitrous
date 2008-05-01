require File.dirname(__FILE__) + '/../test_helper'

class AssertionTest < Test
  test "Assert" do
    assert true
    assert! true
  end
  
  test "Assert equals" do
    assert_equal true, true
    assert_equal! true, true
  end
  
  test "Assert raise" do
    assert_raise do
      raise Exception.new
    end
    assert_raise AssertionFailedError do
      assert! false
    end
  end
end
