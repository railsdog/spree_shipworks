require 'spec_helper'

module SpreeShipworks
  describe Xml do
    let(:context)   { SpreeShipworks::Dsl::Context.new(document, document) }
    let(:document)  { Nokogiri::XML::Document.parse("<?xml version='1.0' standalone='yes'>") }
    let(:order)     { Spree::Order.new.extend(SpreeShipworks::Xml::Order) }
    
    context 'Address' do
      let(:address) {
        Spree::Address.new(
          :address1 => '1234 Test St',
          :address2 => 'Suite #200',
          :city     => 'Testerville',
          :state    => Spree::State.new(:abbr => 'Test'),
          :zipcode  => '12345',
          :country  => Spree::Country.new(:iso_name => 'Testystan'),
          :phone    => '1234567890'
        ).extend(SpreeShipworks::Xml::Address)
      }
      let(:xml) { address.to_xml('Address', context) }

      it 'should have a Street1 node' do
        xml.xpath('/Address/Street1').text.should == address.address1
      end

      it 'should have a Street2 node' do
        xml.xpath('/Address/Street2').text.should == address.address2
      end

      it 'should have a City node' do
        xml.xpath('/Address/City').text.should == address.city
      end

      it 'should have a State node' do
        xml.xpath('/Address/State').text.should == address.state.abbr
      end

      it 'should have a PostalCode node' do
        xml.xpath('/Address/PostalCode').text.should == address.zipcode
      end

      it 'should have a Country node' do
        xml.xpath('/Address/Country').text.should == address.country.iso_name
      end

      it 'should have a Phone node' do
        xml.xpath('/Address/Phone').text.should == address.phone
      end
    end

    context 'Adjustment' do
      let(:adjustment) {
        Spree::Adjustment.new(
          :label  => 'Test',
          :amount => '100.00'
        ).extend(SpreeShipworks::Xml::Adjustment)
      }
      let(:xml) { adjustment.to_xml(context) }

      it 'should have an id attribute' do
        adjustment.id = 10
        xml.xpath('/Total').first['id'].should == adjustment.id.to_s
      end

      it 'should have a name attribute' do
        xml.xpath('/Total').first['name'].should == adjustment.label
      end

      it 'should have an impact attribute' do
        xml.xpath('/Total').first['impact'].should == adjustment.impact
      end

      it 'should have an amount' do
        xml.xpath('/Total').text.should == "100.00"
      end

      it 'should always have a positive amount with the correct impact attribute' do
        adjustment.amount = -100.00
        xml.xpath('/Total').first['impact'].should == 'subtract'
        xml.xpath('/Total').text.should == "100.00"
      end
    end

    context 'Creditcard' do
      let(:creditcard) {
        c = Spree::Creditcard.new(
          :first_name => 'Testy',
          :last_name  => 'Tester',
          :number     => '4111111111111111',
          :verification_value => '111',
          :month => '12',
          :year => '2012'
        ).extend(SpreeShipworks::Xml::Creditcard)
        c.set_last_digits
        c.set_card_type
        c
      }
      let(:xml) { creditcard.to_xml(context) }

      it 'should have a Type node' do
        xml.xpath('/CreditCard/Type').text.should == 'visa'
      end

      it 'should have an Owner node' do
        xml.xpath('/CreditCard/Owner').text.should == creditcard.name
      end

      it 'should have a Number node' do
        xml.xpath('/CreditCard/Number').text.should match(/^XXXX\-/)
        xml.xpath('/CreditCard/Number').text.should match(/1111$/)
      end

      it 'should have an Expires node' do
        xml.xpath('/CreditCard/Expires').text.should match(/^12/)
        xml.xpath('/CreditCard/Expires').text.should match(/2012$/)
        xml.xpath('/CreditCard/Expires').text.should match(/\//)
      end

      it 'should have a CCV node' do
        xml.xpath('/CreditCard/CCV').text.should == '111'
      end
    end

    context 'Item' do
      let(:product) {
        p = Spree::Product.new(:name => 'Test Product')
        p.id = 2
        p
      }
      let(:variant) {
        v = Spree::Variant.new(
          :sku => '1234',
          :price => 10,
          :cost_price => 20,
          :weight => 30
        )
        v.id = 3
        v
      }
      let(:item) {
        i = Spree::LineItem.new(
          :quantity => 4
        ).extend(SpreeShipworks::Xml::LineItem)
        i.id = 1
        i
      }
      let(:xml) { item.to_xml(context) }

      before(:each) do
        item.should_receive(:product).
          at_least(1).times.
          and_return(product)

        item.should_receive(:variant).
          at_least(1).times.
          and_return(variant)
      end

      it 'should have an ItemID node' do
        xml.xpath('/Item/ItemID').text.should == '1'
      end

      it 'should have a ProductID node' do
        xml.xpath('/Item/ProductID').text.should == '2'
      end

      it 'should have a Code node' do
        xml.xpath('/Item/Code').text.should == '3'
      end

      it 'should have a SKU node' do
        xml.xpath('/Item/SKU').text.should == '1234'
      end

      it 'should have a Name node' do
        xml.xpath('/Item/Name').text.should == 'Test Product'
      end

      it 'should have a Quantity node' do
        xml.xpath('/Item/Quantity').text.should == '4'
      end

      it 'should have a UnitPrice node' do
        xml.xpath('/Item/UnitPrice').text.should == '10.00'
      end

      it 'should have a UnitCost node' do
        xml.xpath('/Item/UnitCost').text.should == '20.00'
      end

      it 'should have a Weight node' do
        xml.xpath('/Item/Weight').text.should == '30.0'
      end
    end

    context 'Order' do
      let(:xml) { order.to_xml(context) }

      before(:each) do
        order.should_receive(:created_at).
          and_return(DateTime.now)

        order.should_receive(:updated_at).
          and_return(DateTime.now)

        order.should_receive(:shipping_method).
          at_least(1).times.
          and_return(Spree::ShippingMethod.new(:name => 'Ground'))

        order.should_receive(:ship_address).
          at_least(1).times.
          and_return(Spree::Address.new)

        order.should_receive(:bill_address).
          at_least(1).times.
          and_return(Spree::Address.new)

        order.should_receive(:payments).
          at_least(1).times.
          and_return([Spree::Payment.new])

        order.should_receive(:line_items).
          at_least(1).times.
          and_return([Spree::LineItem.new])

        order.should_receive(:adjustments).
          at_least(1).times.
          and_return([Spree::Adjustment.new])
      end

      it 'should contain the OrderNumber node' do
        xml.xpath('/Order/OrderNumber').should be_present
      end

      it 'should contain the OrderDate node' do
        xml.xpath('/Order/OrderDate').should be_present
      end

      it 'should contain the LastModified node' do
        xml.xpath('/Order/LastModified').should be_present
      end

      it 'should contain the ShippingMethod node' do
        xml.xpath('/Order/ShippingMethod').should be_present
        xml.xpath('/Order/ShippingMethod').text.should == 'Ground'
      end

      it 'should contain the StatusCode node' do
        xml.xpath('/Order/StatusCode').should be_present
      end

      it 'should contain the CustomerID node' do
        xml.xpath('/Order/CustomerID').should be_present
      end

      it 'should contain the ShippingAddress node' do
        xml.xpath('/Order/ShippingAddress').should be_present
      end

      it 'should contain the BillingAddress node' do
        xml.xpath('/Order/BillingAddress').should be_present
      end

      it 'should contain the Payment node' do
        xml.xpath('/Order/Payment').should be_present
      end

      it 'should contain the Items node' do
        xml.xpath('/Order/Items').should be_present
      end

      it 'should contain the Totals node' do
        xml.xpath('/Order/Totals').should be_present
      end
    end

    context 'Payment' do
      let(:payment) {
        Spree::Payment.any_instance.stub(:payment_method).and_return(Spree::Gateway.new)
        Spree::Payment.new(
          :amount => 100,
          :source_attributes => { :year => '2012', :month => '1', :number => '4111111111111111', :verification_value => '123' }
        ).extend(SpreeShipworks::Xml::Payment)
      }
      let(:xml) { payment.to_xml(context) }

      it 'should have a Method node' do
        xml.xpath('/Payment/Method').text.should_not be_empty
        xml.xpath('/Payment/Method').text.should == 'Creditcard'
        xml.xpath('/Payment/CreditCard').should be_present
      end
    end
  end
end
