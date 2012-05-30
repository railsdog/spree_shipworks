module SpreeShipworks
  class GetModule
    include Dsl

    def call(params)
      response do |r|
        r.element "Module" do |r|
          r.element "Platform", "Spree"
          r.element "Developer", "Rails Dog, LLC (http://railsdog.com)"
          r.element "Capabilities" do |r|
            r.element "DownloadStrategy", "ByModifiedTime"
            r.element "OnlineCustomerID", 'supported' => 'true', 'dataType' => 'numeric'
            r.element "OnlineStatus", 'supported' => 'true', 'dataType' => 'text', 'supportsComments' => 'false'
            r.element "OnlineShipmentUpdate", 'supported' => 'true'
          end
        end
      end
    end
  end
end