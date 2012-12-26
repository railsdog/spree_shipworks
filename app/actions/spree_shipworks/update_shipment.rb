module SpreeShipworks
  class UpdateShipment
    include Dsl

    def call(params)
      # shipworks stores the order number as an integer so we must pad it back up to 9 chars
      order = Spree::Order.where(:number => 'R'+params['order'].rjust(9,'0')).first
      if order.nil?
        error_response("NOT_FOUND", "Unable to find an order with ID of '#{params['order']}'.")
      else

        shipment = order.shipments.first
        if shipment.try(:update_attributes, { :tracking => params['tracking'] })
          shipment.ship
          
          response do |r|
            r.element 'UpdateSuccess'
          end
        else
          error_response("UNPROCESSIBLE_ENTITY", "Could not update tracking information for Order ##{params['order']}")
        end
      end

    rescue ActiveRecord::RecordNotFound
      error_response("NOT_FOUND", "Unable to find an order with ID of '#{params['order']}'.")
    rescue => error
      error_response("INTERNAL_SERVER_ERROR", error.to_s)
    end
  end
end
