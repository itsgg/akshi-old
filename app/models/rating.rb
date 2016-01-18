# == Schema Information
#
# Table name: ratings
#
#  id           :integer          not null, primary key
#  owner_id     :integer
#  ratable_id   :integer
#  ratable_type :string(255)
#  score        :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Rating < ActiveRecord::Base
  attr_accessible :owner_id, :ratable_id, :ratable_type, :score
  belongs_to :ratable, :polymorphic => true
  belongs_to :owner, :class_name => 'User'

  validates :owner_id, :presence => true
  validates :ratable_id, :presence => true
  validates :ratable_type, :presence => true
  validates :score, :presence => true
end
