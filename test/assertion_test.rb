require File.dirname(__FILE__) + '/../test_helper'
AssertionFailedError = Nitrous::AssertionFailedError
class AssertionTest < Nitrous::Test
  test "Assert" do
    assert true
    assert! true
  end

  test  "Assert nil" do
    assert_nil! nil
  end

  test "Assert equals" do
    assert_equal true, true
    assert_equal! true, true
  end

  test "Assert raise" do
    assert_raise do
      raise Exception.new
    end

    assert_raise! AssertionFailedError do
      assert! false
    end
  end
end
