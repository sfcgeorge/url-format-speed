Rails.application.routes.draw do
  get "test_nothing" => "tests#test_nothing"
  get "test_nested" => "tests#test_nested"
end
