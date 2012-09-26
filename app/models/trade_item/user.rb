# author: Paul Frischknecht, #11-110-814
module TradeItem
    class User
        attr_accessor :name, :credits, :owned_items #, :password


        ############################
        @@users = []

        def self.all
          @@users
        end

        def self.by_name name
          @@users.detect {|user| user.name == name }
        end

        ###############################

        def self.named(name)
            user = self.new

            fail "Item name too short" unless name.length > 0
            fail "Cannot have multiple users of same name" if self.by_name(name)
            @@users.push(user)

            user.name = name
            user
        end
        
        def add_owned(item)
            self.owned_items.push(item)
        end
        
        def remove_owned(item)
            self.owned_items.delete(item)
        end
        
        def items_to_sell
          self.owned_items.select {|item| item.active}
        end
        
        def initialize
            self.credits = 100
            self.name = "<nameless user>"
            self.owned_items = Array.new
        end
               
        def to_s
            "User #{self.name} with #{self.credits} credits, owns #{self.owned_items.length} items"
        end
    end
end