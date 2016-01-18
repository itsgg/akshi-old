require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test 'routes' do
    assert_recognizes({:controller => 'pages', :action => 'about'}, '/about')
  end
end
