require 'spec_helper'

describe 'UpdateStatus action' do
  # according to the docs, a successful response should look like this
  #
  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.0" schemaVersion="1.0.0">
  #   <UpdateSuccess/>
  # </ShipWorks>

  let(:action) { 'updatestatus' }
  let(:action_params) {
    { 'order' => '1', 'status' => 'next' }
  }
  let(:find_scope) {
    mock('find_scope')
  }

  include_context 'for ShipWorks actions'
  it_should_behave_like 'a ShipWorks API action'

  it 'should respond with success' do
    Spree::Order.should_receive(:find).
      with(action_params['order']).
      and_return(find_scope)

    find_scope.should_receive("#{action_params['status']}!")

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

  it 'should return an error if the state is invalid' do
    Spree::Order.should_receive(:find).
      with(action_params['order']).
      and_return(find_scope)

    klass = Class.new
    machine = StateMachine::Machine.new(klass)
    state   = machine.state(:parked)
    machine.event(action_params['status'].to_sym)

    object = klass.new
    object.state = 'parked'

    invalid_transition = StateMachine::InvalidTransition.new(object, machine, action_params['status'].to_sym)

    find_scope.should_receive("#{action_params['status']}!").
      and_raise(invalid_transition)

    xml.xpath('/ShipWorks/Error').should be_present
    xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_STATUS'
  end

  it 'should return an error if the state can not be used' do
    Spree::Order.should_receive(:find).
      with(action_params['order']).
      and_return(find_scope)

    find_scope.should_receive("#{action_params['status']}!").
      and_raise(NoMethodError)

    xml.xpath('/ShipWorks/Error').should be_present
    xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_STATUS'
  end

  it 'should return an error if any other exceptions are caused' do
    Spree::Order.should_receive(:find).
      with(action_params['order']).
      and_return(find_scope)

    find_scope.should_receive("#{action_params['status']}!").
      and_raise(StandardError)

    xml.xpath('/ShipWorks/Error').should be_present
    xml.xpath('/ShipWorks/Error/Code').text.should == 'INTERNAL_SERVER_ERROR'
  end

end
