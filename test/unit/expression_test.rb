require File.dirname(__FILE__) + '/../test_helper'

class ExpressionTest < Test::Unit::TestCase
  fixtures :expressions

  def setup
    @expression = Expression.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Expression,  @expression
  end
end
