class RemoveTimeLimitFromQuizzes < ActiveRecord::Migration
  def up
    remove_column :quizzes, :time_limit_in_mins
  end

  def down
    add_column :quizzes, :time_limit_in_mins, :integer
  end
end
