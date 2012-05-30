module SpreeShipworks
  module Dsl
    def response(&block)
      xml = Nokogiri::XML::Document.parse "<?xml version='1.0' standalone='yes'>"
      xml.create_element("ShipWorks", :moduleVersion => '3.1.11.0', :schemaVersion => '1.0.0') do |ship_works|
        context = Context.new(xml, ship_works)
        yield context

        xml << ship_works
      end
      xml.to_s
    end

    def error_response(code, description)
      response do |r|
        r.element "Error" do |r|
          r.element "Code", code
          r.element "Description", description
        end
      end
    end

    class Context
      def initialize(document, parent)
        @document = document
        @parent = parent
      end

      def element(name, *contents)
        element_node = @document.create_element(name, *contents)

        if block_given?
          context = Context.new(@document, element_node)
          yield context
        end

        @parent << element_node
      end
    end
  end
end