require 'spec_helper'

describe 'GetModule action' do
  # according to the docs, the response should look something like this

  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.1" schemaVersion="1.0.0">
  #   <Module>
  #     <Platform>Your Platform Name</Platform>
  #     <Developer>Interapptive, Inc. (support@interapptive.com)</Developer> 
  #     <Capabilities>
  #       <DownloadStrategy>ByModifiedTime</DownloadStrategy>
  #       <OnlineCustomerID supported="true" dataType="numeric" />
  #       <OnlineStatus supported="true" dataType="numeric" supportsComments="true" />
  #       <OnlineShipmentUpdate supported="false" /> 
  #     </Capabilities>
  #   </Module>
  # </ShipWorks>

  let(:action) { 'getmodule' }
  let(:action_params) { {} }

  include_context 'for ShipWorks actions'
  it_should_behave_like "a ShipWorks API action"

  it 'should specify the platform name' do
    xml.xpath('/ShipWorks/Module/Platform').text.should == 'Spree'
  end

  it 'should specify the developer name' do
    xml.xpath('/ShipWorks/Module/Developer').text.should == 'Rails Dog, LLC (http://railsdog.com)'
  end

  it 'should specify the modified time download strategy' do
    xml.xpath('/ShipWorks/Module/Capabilities/DownloadStrategy').text.should == 'ByModifiedTime'
  end

  it 'should specify that the customer id is supported' do
    customer_id = xml.at_xpath('/ShipWorks/Module/Capabilities/OnlineCustomerID')
    customer_id['supported'].should == 'true'
    customer_id['dataType'].should == 'numeric'
  end

  it 'should specify that the online status is supported with text status codes, status updates permitted, but comments not supported' do
    status = xml.at_xpath('/ShipWorks/Module/Capabilities/OnlineStatus')
    status['supported'].should == 'true'
    status['dataType'].should == 'text'
    status['supportsComments'].should == 'false'
  end

  it 'should specify that the shipment status can be updated' do
    shipment_update = xml.at_xpath('/ShipWorks/Module/Capabilities/OnlineShipmentUpdate')
    shipment_update['supported'].should == 'true'
  end
end