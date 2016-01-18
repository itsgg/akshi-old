class IncreaseTextFieldLimits < ActiveRecord::Migration
  def change
    change_column :announcements, :content, :text, :limit => 4294967295
    change_column :answers, :content, :text, :limit => 4294967295
    change_column :chats, :content, :text, :limit => 4294967295
    change_column :courses, :description, :text, :limit => 4294967295
    change_column :lessons, :content, :text, :limit => 4294967295
    change_column :questions, :content, :text, :limit => 4294967295
    change_column :quizzes, :instruction, :text, :limit => 4294967295
    change_column :topics, :content, :text, :limit => 4294967295
    change_column :users, :about, :text, :limit => 4294967295
  end
end
