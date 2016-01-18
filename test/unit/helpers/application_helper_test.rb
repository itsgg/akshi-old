require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test 'menu_class' do
    params[:type] = 'home'
    params[:controller] = 'courses'
    assert_nil menu_class('teach')
    assert_equal 'active', menu_class('home')
    assert_nil menu_class('learn')
    assert_nil menu_class('account')
    params[:type] = 'teach'
    assert_equal 'active', menu_class('teach')
    assert_nil menu_class('browse')
    assert_nil menu_class('learn')
    assert_nil menu_class('account')
    params[:type] = 'learn'
    assert_nil menu_class('teach')
    assert_nil menu_class('browse')
    assert_equal 'active', menu_class('learn')
    assert_nil menu_class('account')
    params[:type] = nil
    params[:controller] = 'users'
    params[:action] = 'edit'
    assert_equal 'active', menu_class('account')
    assert_nil menu_class('browse')
    assert_nil menu_class('learn')
    assert_nil menu_class('teach')
  end

  test 'strip html' do
    assert_equal ' hello ', strip_html('<b>hello</b>')
    assert_equal 'rock and roll>', strip_html('rock and roll>')
    assert_equal ' dude', strip_html('&nbsp;dude')
    assert_nil strip_html(nil)
  end

  test 'hash_path' do
    assert_equal '#!/about', hash_path('/about')
    assert_equal '#!', hash_path(nil)
  end

  test 'hash_url' do
    assert_equal 'http://localhost/#!/about',
                  hash_url('http://localhost/about', '/about')
    assert_nil hash_url('http://localhost/', nil)
    assert_nil hash_url(nil, nil)
  end

  test 'basename' do
    assert_equal '/users/gg', basename('/users/gg.rb')
    assert_equal '/users/gg.bak.2342', basename('/users/gg.bak.2342.rb')
  end

  test 'menu_link test' do
    assert menu_link().include?(courses_path(:type => 'browse'))
    assert menu_link('learn').include?(courses_path(:type => 'learn'))
    assert menu_link('teach').include?(courses_path(:type => 'teach'))
  end

  test 'home_page?'do
    params[:controller] = 'courses'
    assert home_page?
    params[:type] = 'home'
    assert home_page?
    params[:type] = 'learn'
    assert !home_page?
    params[:type] = 'teach'
    assert !home_page?
    params[:controller] = 'users'
    params[:type] = 'home'
    assert !home_page?
  end
end
