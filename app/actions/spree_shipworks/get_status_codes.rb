module SpreeShipworks
  class GetStatusCodes
    include Dsl

    def call(params)
      response do |r|
        r.element "StatusCodes" do |r|
          SpreeShipworks::Orders::VALID_STATES.each do |spree_state|
            r.element "StatusCode" do |r|
              r.element "Code", spree_state.to_s
              r.element "Name", spree_state.to_s.titleize
            end
          end
        end
      end
    end
  end
end