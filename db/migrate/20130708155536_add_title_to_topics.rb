class AddTitleToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :title, :string
    Topic.all.each do |topic|
      topic.update_attribute(:title, topic.brief_content[0..79]) if topic.top?
    end
  end
end
