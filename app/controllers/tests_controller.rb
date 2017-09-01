class TestsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :test

  def test
  end
end
