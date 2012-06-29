require 'spree_shipworks/orders'

module SpreeShipworks
  class GetCount
    include Dsl

    def call(params)
      if start_date_valid?(params)
        response do |r|
          r.element "OrderCount", SpreeShipworks::Orders.since(DateTime.parse(params['start'])).count
        end
      else
        error_response("INVALID_DATE_FORMAT", "Unable to determine date format for '#{params['start']}'.")
      end
    end

  private

    def start_date_valid?(params)
      result = true

      if params['start'].present?
        begin
          DateTime.parse(params['start'])
        rescue ArgumentError
          result = false
        end
      end

      result
    end
  end
end