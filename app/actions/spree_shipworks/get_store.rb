module SpreeShipworks
  class GetStore
    include Dsl

    def call(params)
      response do |r|
        r.element "Store" do |r|
          r.element "Name", "#{Spree::Config[:site_name]}"
          r.element "CompanyOrOwner", "Customer Support"
          r.element "Website", "#{Spree::Config[:site_url]}"
        end
      end
    end
  end
end