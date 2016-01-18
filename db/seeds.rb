# Load the default categories
Category.delete_all
['Arts', 'Business', 'Hobbies', 'Education', 'Health', 'Languages',
'Mathematics', 'Science', 'Sports', 'Technology', 'Misc'].each do |category|
  Category.create!(:name => category)
end

# Load the default admin
User.delete_all
User.create!(:username => 'admin', :fullname => 'Akshi admin',
             :password => 'Flipendo123', :password_confirmation => 'Flipendo123',
             :email => 'admin@akshi.com', :admin => true)
