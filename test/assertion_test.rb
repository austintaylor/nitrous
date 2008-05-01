require "../test_helper"

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
    assert! false
    assert_raise AssertionFailedError do
      assert! true
    end
  end
end
