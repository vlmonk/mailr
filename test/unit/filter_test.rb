require File.dirname(__FILE__) + '/../test_helper'

class FilterTest < Test::Unit::TestCase
  fixtures :filters

  def setup
    @filter = Filter.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Filter,  @filter
  end
end
