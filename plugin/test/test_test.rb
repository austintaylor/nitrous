require File.dirname(__FILE__) + '/../test_helper'
class TestTest < Nitrous::Test
  test "setup got called" do
    assert @setup_called
  end

  test "teardown got called" do
    assert @teardown_called
  end

  ztest "should be skipped" do
    @ztest_ran = true
  end

  test "ztests are skipped" do
    assert !@ztest_ran
  end

  test do
    # first line
  end

  def setup
    @setup_called = true
  end

  def teardown
    @teardown_called = true
  end
end
