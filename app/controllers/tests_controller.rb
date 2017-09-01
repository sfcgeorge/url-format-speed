class TestsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def test_nested
  end

  def test_nothing
  end
end
