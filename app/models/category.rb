# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer
#

class Category < ActiveRecord::Base
  attr_accessible :name, :position

  has_many :courses, :dependent => :nullify

  validates :name, :presence => true,
                   :uniqueness => true,
                   :length => 4..80

  default_scope :order => 'categories.position ASC, categories.created_at DESC'

  self.per_page = 10

  def self.order!(ids)
    if ids.present?
      update_all(
        ['position = FIND_IN_SET(id, ?)', ids.join(',')],
        {:id => ids})
    end
  end
end
