# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  session_id :string(255)      not null
#  data       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Session < ActiveRecord::Base
end
