require 'spree_shipworks/xml'

module SpreeShipworks
  class Orders
    VALID_STATES          = %w(complete canceled resumed awaiting_return returned)
    VALID_SHIPMENT_STATES = ::Spree::Shipment.state_machine.events.collect(&:name)

    def self.since(start_date = nil)
      scope = Spree::Order.
                where(:state => VALID_STATES).
                order('updated_at asc')

      if start_date && start_date.to_s != ''
        scope = scope.where('updated_at > ?', DateTime.parse(start_date.to_s))
      end

      scope
    end

    # AR::Base#find_each and AR::Base#find_in_batches do not allow support ordering or limiting
    # This method mimicks the behavior of #find_in_batches, but is specific to the needs of the
    # ShipWorks API since it will break after the maxcount has been reached AND the updated_at
    # attribute has changed since the last order that was found.
    def self.since_in_batches(start_string, maxcount_string)
      if !block_given?
        raise ArgumentError.new("block not given")
      end

      begin
        date = DateTime.parse(start_string)
      rescue
        raise ArgumentError.new("the start variable is invalid")
      end

      batch_size = maxcount_string.to_i
      if batch_size.to_s != maxcount_string
        raise ArgumentError.new("the maxcount variable is invalid")
      end

      batch = 0
      broken = false
      counter = 0
      last_updated_at = nil
      relation = self.since(date).limit(batch_size)

      Spree::Order.uncached do
        orders = relation.offset(batch_size * batch).all
        while orders.any?
          orders.each do |order|
            counter += 1
            if counter > batch_size && last_updated_at != order.updated_at
              broken = true
              break
            end
            order.extend(Xml::Order)
            last_updated_at = order.updated_at
            yield order
          end
          break if orders.size < batch_size || broken
          orders = relation.offset(batch_size * (batch += 1)).all
        end
      end
    end
  end
end
