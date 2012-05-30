module SpreeShipworks
  class UpdateStatus
    include Dsl

    def call(params)
      Spree::Order.find(params['order']).send("#{params['status']}!".to_sym)

      response do |r|
        r.element 'UpdateSuccess'
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