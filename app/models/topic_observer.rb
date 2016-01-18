class TopicObserver < ActiveRecord::Observer

  def after_create(topic)
    users_to_notify = topic.course.teachers

    unless topic.top?
      # All the users in the replies, top topic user
      parent_topic = Topic.find(topic.parent_id)
      users_to_notify += [parent_topic.user]
      replies = Topic.where(:parent_id => parent_topic.id)
      users_to_notify += replies.map(&:user)
    end

    users_to_notify.uniq.each do |user|
      if topic.user != user && user.discussion_notify?
        UserMailer.send_discussion(user.id, topic.id).deliver
      end
    end
  end
end
