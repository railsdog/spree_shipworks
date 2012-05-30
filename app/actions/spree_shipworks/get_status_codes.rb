module SpreeShipworks
  class GetStatusCodes
    include Dsl

    def call(params)
      response do |r|
        r.element "StatusCodes" do |r|
          Spree::Order.state_machine.states.each do |spree_state|
            r.element "StatusCode" do |r|
              r.element "Code", spree_state.name
              r.element "Name", spree_state.name.titleize
            end
          end
        end
      end
    end
  end
end