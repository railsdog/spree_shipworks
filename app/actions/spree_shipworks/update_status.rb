module SpreeShipworks
  class UpdateStatus
    include Dsl

    def call(params)
      if order = Spree::Order.find(params['order'])
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