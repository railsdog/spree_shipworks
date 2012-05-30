require 'spree_shipworks/orders'

module SpreeShipworks
  class GetOrders
    include Dsl

    def call(params)
      response do |r|
        r.element 'Orders' do |r|
          ::SpreeShipworks::Orders.since(params['start'], params['maxcount']) do |order|
            order.to_xml(r)
          end
        end
      end
    rescue ArgumentError => error
      error_response("INVALID_VARIABLE", error.to_s + "\n" + error.backtrace.join("\n"))
    rescue => error
      Rails.logger.error(error.to_s)
      Rails.logger.error(error.backtrace.join("\n"))
      error_response("INTERNAL_SERVER_ERROR", error.to_s)
    end
  end
end
