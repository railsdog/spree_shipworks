require 'spec_helper'

describe 'HandleUnknown actions' do

  # according to the docs, an error response should look something like this:
  #
  # <?xml version="1.0" standalone="yes" ?>
  # <ShipWorks moduleVersion="3.0.0" schemaVersion="1.0.0">
  #   <Error>
  #     <Code>FOO100</Code>
  #     <Description>Something Failed. Internal Error.</Description>
  #   </Error>
  # </ShipWorks>

  let(:action) { 'unknownaction' }
  let(:action_params) { {} }

  include_context 'for ShipWorks actions'
  it_should_behave_like 'a ShipWorks API action'

  it 'should return an error if the action is unknown' do
    xml.xpath('/ShipWorks/Error').should be_present
    xml.xpath('/ShipWorks/Error/Code').text.should == 'NOT_FOUND'
  end
end
