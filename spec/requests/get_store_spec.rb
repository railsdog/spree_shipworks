require 'spec_helper'

describe 'GetStore action' do
  # based on information in the XML schema definition, the response should look something like this

  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.1" schemaVersion="1.0.0">
  #   <Store>
  #     <Name>My Example Store</Name>
  #     <Website>http://spree.example.com</Website>
  #   </Store>
  # </ShipWorks>

  let(:action) { 'getstore' }
  let(:action_params) { {} }

  include_context 'for ShipWorks actions'
  it_should_behave_like "a ShipWorks API action"

  it 'should use the store name from Spree configuration settings' do
    Spree::Config.set :site_name => 'Awesome Spree Store'
    xml.xpath('/ShipWorks/Store/Name').text.should == 'Awesome Spree Store'
  end

  it 'should use the store site url from Spree configuration settings' do
    Spree::Config.set :site_url => 'http://spree.awesomeness.com'
    xml.xpath('/ShipWorks/Store/Website').text.should == 'http://spree.awesomeness.com'
  end
end