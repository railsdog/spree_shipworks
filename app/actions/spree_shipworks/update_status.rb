module SpreeShipworks
  class UpdateStatus
    include Dsl

    def call(params)
      # shipworks stores the order number as an integer so we must pad it back up to 9 chars
      order = Spree::Order.where(:number => 'R'+params['order'].rjust(9,'0')).first      
      if order.nil?
        error_response("NOT_FOUND", "Unable to find an order with ID of '#{params['order']}'.")
      else
        order.shipments.each do |shipment|
          shipment.send("#{params['status']}!".to_sym)
        end

        response do |r|
          r.element 'UpdateSuccess'
        end
      end

    rescue ActiveRecord::RecordNotFound
      error_response("NOT_FOUND", "Unable to find an order with ID of '#{params['order']}'.")
    rescue StateMachine::InvalidTransition, NoMethodError => error
      error_response("INVALID_STATUS", error.to_s)
    rescue => error
      error_response("INTERNAL_SERVER_ERROR", error.to_s)
    end
  end
end