# author: Paul Frischknecht, #11-110-814
module TradeItem
    class Item
        attr_accessor :name, :price, :active, :owner
        
         # class variable
        @@items = []
        
        def self.all
          @@items
        end

        def self.by_name name
          @@items.detect {|item| item.name == name }
        end

        def self.delete item
          @@items.delete(item)
        end

        # when would this be called, by who? why not just add every instance? We'll do that.
        # add the instance to the list of items
        #def save
        #  @@items << self # or @@items.push(self)
        #end
        
        ##########################
        def self.named_priced_owned(name, price, owner)
            item = self.new

            fail "Item name too short" unless name.length > 0
            fail "Cannot have multiple items of same name" if self.by_name(name)
            @@items.push(item)
            
            item.name = name
            item.price = Integer(price)
            item.owner = owner
            owner.add_owned(item)
            item
        end
        
        def can_buy?(buyer)
            buyer.credits >= self.price and self.active and buyer != self.owner         
        end
        
        def buy(buyer)
            fail "Cannot buy (not enough credits, inactive or are already owner)" unless self.can_buy?(buyer)
            
            owner.credits += self.price
            buyer.credits -= self.price
            self.owner.remove_owned(self)
            self.owner = buyer            
            buyer.add_owned(self)
            self.active = false
                 
        end
        
        def initialize
            self.price = 0
            self.name = "<unnamed item>"
            self.active = false
        end
        
        def to_s
            a = "inactive"
            if self.active
                a = "active"
            end
            "Item #{self.name} owned by #{self.owner.name} costs #{self.price} credits is #{a} (for trading)"
        end
    end
end