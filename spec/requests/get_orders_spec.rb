require 'spec_helper'

describe 'GetOrders action' do
  # according to the docs, the response should look something like this

  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.1" schemaVersion="1.0.0">
  #   <Orders>
  #     <Order>
  #       <OrderNumber>12345</OrderNumber>
  #       <OrderDate>2012-08-21T11:58:59</OrderDate>
  #       <!-- Optional -->
  #       <LastModified>2012-08-21T11:58:59</LastModified>
  #       <ShippingMethod>USPS Flat Rate</ShippingMethod>
  #       <!-- Optional -->
  #       <StatusCode>completed</StatusCode>
  #       <!-- Optional -->
  #       <CustomerID>12345</CustomerID>
  #       <!-- Optional -->
  #       <Notes>
  #         <!-- Optional; Many -->
  #         <Note>This is a note</Note>
  #         <Note>This is another note</Note>
  #       </Notes>
  #       <ShippingAddress>
  #         <FirstName>Naruto</FirstName>
  #         <LastName>Uzamaki</LastName>
  #         <!-- Optional -->
  #         <Company>Konohagakure no Sato</Company>
  #         <Street1>1 Anywhere Street</Street>
  #         <Street2>Apt 2</Street2>
  #         <City>Richmond</City>
  #         <State>VA</State>
  #         <PostalCode>23224</PostalCode>
  #         <Country>US</Country>
  #         <Phone>8885551212</Phone>
  #       </ShippingAddress>
  #       <BillingAddress>
  #         <FirstName>Naruto</FirstName>
  #         <LastName>Uzamaki</LastName>
  #         <!-- Optional -->
  #         <Company>Konohagakure no Sato</Company>
  #         <Street1>1 Anywhere Street</Street>
  #         <Street2>Apt 2</Street2>
  #         <City>Richmond</City>
  #         <State>VA</State>
  #         <PostalCode>23224</PostalCode>
  #         <Country>US</Country>
  #         <Phone>8885551212</Phone>
  #       </BillingAddress>
  #       <!-- Optional -->
  #       <Payment>
  #         <Method>Visa</Method>
  #         <!-- Optional -->
  #         <CreditCard>
  #           <Type>Visa</Type>
  #           <Owner>Naruto Uzamaki</Owner>
  #           <Number>XXXX-XXXX-XXXX-1234</Number>
  #           <Expires>08/2012</Expires>
  #           <!-- Optional -->
  #           <CCV>123</CCV>
  #         </CreditCard>
  #         <!-- Optional; Many -->
  #         <Detail name='Gift Card' value='1234567' />
  #         <!-- Optional; Many -->
  #         <Detail name='Discount Code' value='ABCD' />
  #       </Payment>
  #       <Items>
  #         <!-- Optional; Many -->
  #         <Item>
  #           <!-- Optional -->
  #           <ItemID>13241</ItemID>
  #           <!-- Optional -->
  #           <!-- Use variant.id? -->
  #           <ProductID>13413</ProductID>
  #           <!-- Use product.id? -->
  #           <Code>13431</Code>
  #           <!-- Optional -->
  #           <SKU>ROR-00012</SKU>
  #           <!-- Optional -->
  #           <Name>Ruby on Rails Bag</Name>
  #           <Quantity>1</Quantity>
  #           <UnitPrice>22.99</UnitPrice>
  #           <!-- Optional -->
  #           <UnitCost>21.00</UnitCost>
  #           <!-- Optional -->
  #           <Image>http://url.to/image</Image>
  #           <!-- Optional -->
  #           <ThumbnailImage>http://url.to/image</ThumbnailImage>
  #           <Weight>3.2</Weight>
  #           <!-- Optional -->
  #           <Attributes>
  #             <!-- Optional; Many -->
  #             <Attribute>
  #               <!-- Optional -->
  #               <AttributeID></AttributeID>
  #               <Name>Size</Name>
  #               <Value>M</Value>
  #               <!-- Optional -->
  #               <!-- We should exclude this, because it will throw off cost cacluation -->
  #               <Price></Price>
  #             </Attribute>
  #             <Attribute>
  #               <Name>Color</Name>
  #               <Value>Green</Name>
  #             </Attribute>
  #           </Attributes>
  #         </Item>
  #       </Items>
  #       <!-- These equate to spree adjustments -->
  #       <Totals>
  #         <!-- Optional; Many -->
  #         <Total id='1234' name='Shipping' impact='add'>12.24</Total>
  #         <Total id='1235' name='Coupon' impact='subtract'>1.33</Total>
  #         <Total id='1236' name='Tax' impact='add'>1.22</Total>
  #       </Totals>
  #     </Order>
  #   </Orders>
  # </ShipWorks>

  let(:action) { 'getorders' }
  let(:action_params) {
    { 'start' => '2012-01-01T11:59:00', 'maxcount' => '50' }
  }

  include_context 'for ShipWorks actions'
  it_should_behave_like "a ShipWorks API action"

  context 'with a missing start param' do
    let(:action_params) {
      { 'maxcount' => '50' }
    }

    it 'should return an error' do
      xml.xpath('/ShipWorks/Error').should be_present
      xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_VARIABLE'
    end
  end

  context 'with an invalid start param' do
    let(:action_params) {
      { 'start' => 'test', 'maxcount' => '50' }
    }

    it 'should return an error' do
      xml.xpath('/ShipWorks/Error').should be_present
      xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_VARIABLE'
    end
  end

  context 'with a missing maxcount param' do
    let(:action_params) {
      { 'start' => '2012-01-01T11:59:00' }
    }

    it 'should return an error' do
      xml.xpath('/ShipWorks/Error').should be_present
      xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_VARIABLE'
    end
  end

  context 'with an invalid maxcount param' do
    let(:action_params) {
      { 'start' => '2012-01-01T11:59:00', 'maxcount' => 'test' }
    }

    it 'should return an error' do
      xml.xpath('/ShipWorks/Error').should be_present
      xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_VARIABLE'
    end
  end

  context 'with valid params' do
    let(:action_params) {
      { 'start' => '2012-01-01T00:00:00', 'maxcount' => '5' }
    }
    let(:order) {
      Spree::Order.new.extend(SpreeShipworks::Xml::Order)
    }

    it 'should return valid xml' do
      order.should_receive(:created_at).
        and_return(DateTime.now)
      order.should_receive(:updated_at).
        and_return(DateTime.now)

      SpreeShipworks::Orders.should_receive(:since_in_batches).
        with(action_params['start'], action_params['maxcount']).
        and_yield(order)

      xml.xpath('/ShipWorks/Orders').should be_present
      xml.xpath('/ShipWorks/Orders/Order').length.should == 1
    end
  end

  context 'with valid params and a complex order' do
    let(:action_params) {
      { 'start' => '2012-01-01T00:00:00', 'maxcount' => '5' }
    }

    it 'should not crash' do
      # need to create the admin user before creating the order
      create_admin_user

      order = Spree::Order.create!
      order.payments.create!

      SpreeShipworks::Orders.should_receive(:since_in_batches).
        with(action_params['start'], action_params['maxcount']).
        and_yield(order.extend(SpreeShipworks::Xml::Order))

      xml.xpath('/ShipWorks/Error/Code').should_not be_present
      xml.xpath('/ShipWorks/Orders').should be_present
      xml.xpath('/ShipWorks/Orders/Order').length.should == 1
    end
  end
end
