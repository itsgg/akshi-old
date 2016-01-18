Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == Setting.resque.user && password == Setting.resque.password
end
