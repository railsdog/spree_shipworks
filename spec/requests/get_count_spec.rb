require 'spec_helper'

describe 'GetCount action' do
  # according to the docs, the response should look something like this

  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.1" schemaVersion="1.0.0">
  #   <OrderCount>42</OrderCount>
  # </ShipWorks>

  let(:action)        { 'getcount' }
  let(:action_params) { { 'start' => '2012-01-01T11:59:00' } }
  let(:date_string)   { action_params['start'] }
  let(:date)          { DateTime.parse(date_string) }
  let(:order_scope)   { mock('order_scope') }

  include_context 'for ShipWorks actions'
  it_should_behave_like "a ShipWorks API action"

  it 'should respond with number of orders that where updated after the specified date' do
    SpreeShipworks::Orders.should_receive(:since).
      with(date).and_return(order_scope)

    order_scope.should_receive(:count).and_return(125)

    xml.xpath('/ShipWorks/OrderCount').text.should == '125'
  end

  context 'with missing date param' do
    let(:action_params) { {} }

    it 'should return the total number of orders' do
      SpreeShipworks::Orders.should_receive(:since).
        with(date_string).and_return(order_scope)

      order_scope.should_receive(:count).
        and_return(321)

      xml.xpath('/ShipWorks/OrderCount').text.should == '321'
    end
  end

  context 'with blank start date' do
    let(:action_params) { { 'start' => '' } }

    it 'should return the total number of orders' do
      SpreeShipworks::Orders.should_receive(:since).
        with(date_string).and_return(order_scope)

      order_scope.should_receive(:count).
        and_return(1221)

      xml.xpath('/ShipWorks/OrderCount').text.should == '1221'
    end
  end

  context 'with invalid start date format' do
    let(:action_params) { { 'start' => 'blargh' } }

    it 'should respond with an error response' do
      xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_DATE_FORMAT'
      xml.xpath('/ShipWorks/Error/Description').text.should == "Unable to determine date format for 'blargh'."
    end
  end
end