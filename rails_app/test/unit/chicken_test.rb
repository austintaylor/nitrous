require 'test_helper'

class ChickenTest < Nitrous::RailsTest

  test "the chicken can cluck" do
    Chicken.create(:name => "Austin")
    assert created(:chicken) do
      assert_equal "Austin", created(:chicken).name
    end
    
    Chicken.create(:name => "Saki")
    assert created(:chicken) do
      assert_equal "Saki", created(:chicken).name
    end
    assert_equal 2, created(:chickens).size
  end
end
