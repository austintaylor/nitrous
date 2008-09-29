require File.dirname(__FILE__) + '/../test_helper'

class ChickenWalkTest < Nitrous::IntegrationTest
  test "create a chicken" do
    navigate_to new_chicken_path
    submit_form :chicken => {:name => "Paul"}
    assert created(:chicken) do
      assert_equal "Paul", created(:chicken).name
    end
    assert_viewing chickens_path
  end
end
