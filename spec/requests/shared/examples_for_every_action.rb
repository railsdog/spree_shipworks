shared_examples "a ShipWorks API action" do
  XML_DECLARATION_REGEX = /^<\?xml\W*version=['"]1.0['"]\W*standalone=['"]yes['"]\W*?>/ unless defined?(XML_DECLARATION_REGEX)

  it 'should specify the gem version' do
    ship_works = xml.at_xpath('/ShipWorks')
    ship_works['moduleVersion'].should == '3.1.11.0'
  end
  
  it 'should specify the ShipWorks schema version' do
    ship_works = xml.at_xpath('/ShipWorks')
    ship_works['schemaVersion'].should == '1.0.0'
  end

  it 'should respond with a valid xml document' do
    xml.errors.should == []
  end

  it 'should validate against the xml schema definition' do
    schema = Nokogiri::XML::Schema(File.read(File.expand_path('../../../../docs/ShipWorks1_0_0.xsd', __FILE__)))
    schema.valid?(xml).should be_true
  end

  it 'should have an xml declaration' do
    valid_user_api_response.body.should match XML_DECLARATION_REGEX
  end

  it 'should respond with a "text/xml" content type' do
    valid_user_api_response.content_type.should == 'text/xml'
  end

  context 'with invalid user' do
    it 'should respond with a "text/xml" content type' do
      invalid_user_api_response.content_type.should == 'text/xml'
    end

    it 'should have an xml processing instruction' do
      invalid_user_api_response.body.should match XML_DECLARATION_REGEX
    end

    it 'should respond with a valid xml document' do
      invalid_user_xml.errors.should == []
    end

    # according to the documentation, the error response should look something
    # like the following:

    # <?xml version="1.0" standalone="yes" ?>
    # <ShipWorks moduleVersion="3.0.0" schemaVersion="1.0.0">
    #   <Error>
    #     <Code>INVALID_USER_OR_PASSWORD</Code>
    #     <Description>Invalid username or password</Description>
    #   </Error>
    # </ShipWorks>
    it 'should respond with an error document' do
      invalid_user_xml.xpath('/ShipWorks/Error/Code').text.should == 'INVALID_USER_OR_PASSWORD'
      invalid_user_xml.xpath('/ShipWorks/Error/Description').text.should == 'Invalid username or password'
    end
  end

  context 'with valid user, but not admin' do
    it 'should respond with a "text/xml" content type' do
      unauthorized_user_api_response.content_type.should == 'text/xml'
    end

    it 'should have an xml processing instruction' do
      unauthorized_user_api_response.body.should match XML_DECLARATION_REGEX
    end

    it 'should respond with a valid xml document' do
      unauthorized_user_xml.errors.should == []
    end


    # according to the documentation, the error response should look something
    # like the following:

    # <?xml version="1.0" standalone="yes" ?>
    # <ShipWorks moduleVersion="3.0.0" schemaVersion="1.0.0">
    #   <Error>
    #     <Code>UNAUTHORIZED_USER</Code>
    #     <Description>The specified user is not a Spree administrator.</Description>
    #   </Error>
    # </ShipWorks>
    it 'should respond with an error document' do
      unauthorized_user_xml.xpath('/ShipWorks/Error/Code').text.should == 'UNAUTHORIZED_USER'
      unauthorized_user_xml.xpath('/ShipWorks/Error/Description').text.should == 'The specified user is not a Spree administrator.'
    end
  end
end
