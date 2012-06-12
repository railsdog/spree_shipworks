require 'spec_helper'

describe 'GetStatusCodes action' do
  # according to the docs, the response should look something like this

  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.1" schemaVersion="1.0.0">
  #   <StatusCodes>
  #     <StatusCode>
  #       <Code>complete</Code>
  #       <Name>complete</Name>
  #     </StatusCode>
  #     <StatusCode>
  #       <Code>canceled</Code>
  #       <Name>canceled</Name>
  #     </StatusCode>
  #   </StatusCodes>
  # </ShipWorks>

  let(:action) { 'getstatuscodes' }
  let(:action_params) { {} }

  include_context 'for ShipWorks actions'
  it_should_behave_like "a ShipWorks API action"

  it 'the number of status codes should be the same as the number of states on Spree::Order' do
    xml.xpath('/ShipWorks/StatusCodes/StatusCode').length.should == SpreeShipworks::Orders::VALID_STATES.length
  end

  SpreeShipworks::Orders::VALID_STATES.each do |state|
    it "should include #{state} state" do
      xml.xpath("/ShipWorks/StatusCodes/StatusCode/Code[contains(.,'#{state}')]").text.should == state.to_s
      xml.xpath("/ShipWorks/StatusCodes/StatusCode/Name[contains(.,'#{state.to_s.titleize}')]").text.should == state.to_s.titleize
    end
  end
end