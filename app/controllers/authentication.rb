# User authentication -- If the user is not authenticated, he/she is redirect to the login page. Authentication suceeds if the password = the username.

def checkLogin
  redirect '/login' unless session[:name] # doesn't seem to work well session[:user]
end

def session_user
  TradeItem::User.by_name(session[:name])
end

get "/login" do
  haml :login
end

post "/login" do
  user = TradeItem::User.by_name(params[:username])

  if !user or params[:password] != user.name
    redirect '/'
    return # doesn't appear to be necessary...
  end

  session[:name] = user.name
  redirect '/'
end

post "/register" do
  TradeItem::User.named(params[:name])

  redirect '/login'
end

# cannot use post because browser submits "get" when clicking on links.

# well then just use a form...
post '/logout' do
  session[:name] = nil
  redirect '/'
end