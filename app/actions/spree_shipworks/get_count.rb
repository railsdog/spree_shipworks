module SpreeShipworks
  class GetCount
    include Dsl

    def call(params)
      if start_date_valid?(params)
        response do |r|
          r.element "OrderCount", number_of_orders_since(params['start'])
        end
      else
        error_response("INVALID_DATE_FORMAT", "Unable to determine date format for '#{params['start']}'.")
      end
    end

    private

    def number_of_orders_since(start_date)
      scope = Spree::Order

      if start_date.present?
        scope = Spree::Order.where('updated_at > ?', DateTime.parse(start_date))
      end

      scope.count
    end

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