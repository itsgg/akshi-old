# == Schema Information
#
# Table name: sites
#
#  id           :integer          not null, primary key
#  broadcasting :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  test 'Singleton' do
    assert_raise NoMethodError do
      Site.new
    end
    assert_raise NoMethodError do
      Site.first
    end
  end

  test 'broadcast!' do
    Site.instance.broadcast!
    assert Site.instance.broadcasting?
  end
end
