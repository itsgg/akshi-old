# == Schema Information
#
# Table name: sites
#
#  id           :integer          not null, primary key
#  broadcasting :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Site < ActiveRecord::Base
  attr_accessible :broadcasting
  acts_as_singleton

  def broadcast!
    self.update_attribute(:broadcasting, true)
  end
end
