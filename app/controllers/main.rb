configure do
  # Test data -- Please prepare test data that are loaded on startup. The must be a user ese that we can use to log in the system and test the other features.
  ese = TradeItem::User.named( 'ese')

  paul = TradeItem::User.named( 'Paul')

  i = TradeItem::Item.named_priced_owned( 'Game Boy', 30, paul)
  i.active = true
  i = TradeItem::Item.named_priced_owned( 'Game Boy Color', 70, paul)
  i.active = true
  i = TradeItem::Item.named_priced_owned( 'NDS', 100, paul)

  enable :sessions
end

# Show all active items -- The default page lists all active items in the system. For each item there is
# the name, the price, a link to the owner, a link to buy the item
get "/" do
  checkLogin
  @user = session_user
  @items = TradeItem::Item.all.select {|item| item.active} # and item.owner != session_user} # addition... don't list user's items
  haml :buy_items
end

# Buy an item -- From the default page, a user can buy an item. If the transaction suceeds, the page is updated to show the new state of the system; otherwise an exception is raised.

# cannot use POST since it needs to be " a link to buy the item" and links are always used with GET...
get "/buy/:name" do
  checkLogin
  TradeItem::Item.by_name(params[:name]).buy(session_user)
  redirect '/'
end

# List items of a user -- The page lists all items owned by the user and indicates whether they are active (to sell) or inactive (not to sell).
get "/user/:name" do
  checkLogin
  @user = TradeItem::User.by_name(params[:name])
  @items = @user.owned_items

  haml :user
end

# Additional content not required
get "/myitems" do
  checkLogin
  @user = session_user
  @items = @user.owned_items
  for i in @items
    puts i.name
  end

  for i in TradeItem::User.all
    puts i.name

    for j in i.owned_items
      puts "-#{j.name}"
    end
  end
  haml :myitems
end

get "/activate/:name" do
  checkLogin
  item = TradeItem::Item.by_name(params[:name])
  fail "This is not your item" unless item.owner == session_user
  item.active = true
  redirect '/myitems'
end

get "/deactivate/:name" do
  checkLogin
  item = TradeItem::Item.by_name(params[:name])
  fail "This is not your item" unless item.owner == session_user
  item.active = false
  redirect '/myitems'
end

get "/delete_item/:name" do
  checkLogin
  item = TradeItem::Item.by_name(params[:name])
  fail "This is not your item" unless item.owner == session_user
  item.owner.remove_owned(item)
  TradeItem::Item.delete(item)
  redirect '/myitems'
end

post '/add_item' do
  checkLogin
  TradeItem::Item.named_priced_owned(params[:name], params[:price], session_user)
  redirect '/myitems'
end

