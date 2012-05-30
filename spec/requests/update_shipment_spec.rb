require 'spec_helper'

describe 'UpdateShipment action' do
  # according to the docs, a successful response should look like this
  #
  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.0" schemaVersion="1.0.0">
  #   <UpdateSuccess/>
  # </ShipWorks>

  let(:action) { 'updateshipment' }
  let(:action_params) {
    { 'order' => '1', 'tracking' => '1' }
  }
  let(:find_scope) {
    mock('find_scope')
  }
  let(:shipments_scope) {
    mock('shipments_scope')
  }
  let(:shipment_scope) {
    mock('shipment_scope')
  }

  include_context 'for ShipWorks actions'
  it_should_behave_like 'a ShipWorks API action'

  it 'should respond with success' do
    Spree::Order.should_receive(:find).
      with(action_params['order']).
      and_return(find_scope)

    find_scope.should_receive(:shipments).
      and_return(shipments_scope)

    shipments_scope.should_receive(:first).
      and_return(shipment_scope)

    shipment_scope.should_receive(:try).
      with(:update_attributes, { :tracking => action_params['tracking'] }).
      and_return(true)

    xml.xpath('/ShipWorks/UpdateSuccess').should be_present
  end

  # according to the docs, an error response should look something like this:
  #
  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.0" schemaVersion="1.0.0">
  #   <Error>
  #     <Code>FOO100</Code>
  #     <Description>Something Failed. Internal Error.</Description>
  #   </Error>
  # </ShipWorks>

  it 'should return an error if the order can not be found' do
    Spree::Order.should_receive(:find).
      with(action_params['order']).
      and_raise(ActiveRecord::RecordNotFound)

    xml.xpath('/ShipWorks/Error').should be_present
    xml.xpath('/ShipWorks/Error/Code').text.should == 'NOT_FOUND'
  end

  it 'should return an error if the order is missing shipments' do
    Spree::Order.should_receive(:find).
      with(action_params['order']).
      and_return(find_scope)

    find_scope.should_receive(:shipments).
      and_return(shipments_scope)

    shipments_scope.should_receive(:first).
      and_return(nil)

    xml.xpath('/ShipWorks/Error').should be_present
    xml.xpath('/ShipWorks/Error/Code').text.should == 'UNPROCESSIBLE_ENTITY'
  end
end
