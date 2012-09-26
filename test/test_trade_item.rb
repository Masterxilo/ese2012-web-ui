# author: Paul Frischknecht, #11-110-814
require 'test/unit'
require '../app/models/trade_item/user' # file must be run from within its folder!!!
require '../app/models/trade_item/item'

class TestTradeItem < Test::Unit::TestCase
    def test_user_name
        # Users have a name
        user = TradeItem::User.named('John')
        assert( user.to_s.include?(' John '), 'User name is incorrect')
    end

    def test_credits
        # Users have an amount of credits
        user = TradeItem::User.named('John')
        assert( user.to_s.include?('100 credits'), 'User credit not found')
    end
    
    def test_100credits
        # A new user has originally 100 credit(s?). 
        user = TradeItem::User.named('John')
        assert( user.to_s.include?(' 100 '), 'User credit wrong')
    end
    
    def test_itemname
        # Items have a name.
        user = TradeItem::User.named('John')
        item = TradeItem::Item.named_priced_owned('GameBoy', 230,user)
        assert( item.to_s.include?('GameBoy'), 'Item name wrong')
    end
    
    def test_itemprice
        # Items have a price.
        user = TradeItem::User.named('John')
        item = TradeItem::Item.named_priced_owned('GameBoy', 230,user)
        assert( item.to_s.include?(' 230 credits'), 'Item price wrong or missing')
    end
    
    def test_item_has_activity_state
        # An item can be active or inactive.
        user = TradeItem::User.named('John')
        item = TradeItem::Item.named_priced_owned('GameBoy', 230,user)
        assert(!item.active, 'Item active state missing or wrong, should be false')
        item.active = false
        assert(!item.active, 'Item active state missing or wrong, should be false')
        assert(item.to_s.include?('is inactive'), 
        'Item active state missing or wrong in string, should be inactive')
        
        item.active = true
        assert(item.active, 'Item active state missing or wrong')
        assert(item.to_s.include?('is active'), 'Item active state missing or wrong')
    end
    
    def test_item_owed
        # An item has an owner.
        user = TradeItem::User.named('John')
        item = TradeItem::Item.named_priced_owned('GameBoy', 230,user)
        assert(item.to_s.include?('owned by John'), 'Item has no owner')
    end
    
    def test_item_initial_inactive
        # A user can add a new item to the system with a name and a price; the item is originally inactive.
        user = TradeItem::User.named('John')
        item = TradeItem::Item.named_priced_owned('GameBoy', 230,user)
        
        assert(item.to_s.include?('GameBoy'), 'Item has no name')
        assert(item.to_s.include?(' 230 '), 'Item has wrong/no price')
        assert(!item.active, 'Item active state missing or wrong, should be false')
    end
    
    # ====================
    # Need to provide 3 tests for *second to last* requirement.
    # A user can buy active items of another user (inactive items can't be bought).
    # When a user buys an item, it becomes the owner; credit are transferred accordingly;
    # immediately after the trade, the item is inactive. The transaction fails if the buyer has !enough credits.
    def test_buy_active
        user1 = TradeItem::User.named('John')
        user2 = TradeItem::User.named('Tim')
        item = TradeItem::Item.named_priced_owned('GameBoy', 80,user1)
        item.active = true
        assert(item.owner == user1, 'Item owner wrong before trade')

        assert(item.can_buy?(user2), "Buying failed when it shouldn't")
        item.buy(user2)
        assert(user1.to_s.include?(' owns 0 items'), 'Item still owned by old owner')
        assert(user1.credits == 180, 'User1 did !get credits')
        assert(user2.credits == 20, 'User2 did !give credits')
        assert(user2.to_s.include?(' owns 1 items'), 'Item !owned by new owner')
        assert(item.owner == user2, 'Item !owned by new owner')
        assert(!item.active, 'Item should !be active after trade')
    end
    
    def test_no_buy_inactive
        user1 = TradeItem::User.named('John')
        user2 = TradeItem::User.named('Tim')
        item = TradeItem::Item.named_priced_owned('GameBoy', 80,user1)
        # item.active = false # by default
        assert(!item.can_buy?(user2), "Buying succeded when it shouldn't")
    end
    
    def test_no_buy_missing_credit
        user1 = TradeItem::User.named('John')
        user2 = TradeItem::User.named('Tim')
        item = TradeItem::Item.named_priced_owned('GameBoy', 230,user1)
        item.active = true
        assert(!item.can_buy?(user2), "Buying succeded when it shouldn't")
    end
    # ====================
    
    def test_active_itemlist
        #A user provides a method that lists his/her active items to sell.
        user = TradeItem::User.named('John')
        item1 = TradeItem::Item.named_priced_owned('GameBoy', 230,user)
        item2 = TradeItem::Item.named_priced_owned('NDS', 300,user)
        item3 = TradeItem::Item.named_priced_owned('GBC', 250,user)
        item1.active = true
        item3.active = true

        assert(user.owned_items.length == 3, 'Wrong amount of items')

        l = user.items_to_sell
        
        assert(l.include?(item1), 'Active item !in list')
        assert(!l.include?(item2), 'Inactive item in list')
        assert(l.include?(item3), 'Active item !in list')
        assert(l.length == 2, 'Wrong amount of active items')
    end
end

