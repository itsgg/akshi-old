class AddTimeLimitInMinutesToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :time_limit_in_minutes, :float, :default => 0
  end
end
