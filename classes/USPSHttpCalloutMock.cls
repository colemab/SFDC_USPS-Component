global class USPSHttpCalloutMock implements HttpCalloutMock {
	
	// Test coverage for this class is provided by the USPS.cls testing
	
	global HTTPResponse respond(HTTPRequest req) {
		
		string IncomingRequest = req.getEndpoint(); 		
		system.debug('Incoming EndPoint: ' + IncomingRequest);
			
		System.Httpresponse ReturnValue = new System.Httpresponse();
		
		string XMLValue = '';
		
		// to increase test coverage, we vary our response when certain key words are present
		if (IncomingRequest.contains('ERROR')) {

			// starting XML tags
			XMLValue = '<?xml version=\"1.0\"?><AddressValidateResponse><Address ID=\"0\">';
			
			// error
			XMLValue += '<Error><Number>-2147219401</Number>';
			XMLValue += '<Source>API_AddressCleancAddressClean.CleanAddress2;SOLServer.CallAddressDll</Source>';
			XMLValue += '<Description>Address Not Found.</Description>';
			
			// closing XML tags
			XMLValue += '</Error></Address></AddressValidateResponse>';

			
		} else if (IncomingRequest.contains('NULL')) {
			// starting XML tags
			XMLValue = '<?xml version=\"1.0\"?><AddressValidateResponse><Address ID=\"0\">';
			
			// return a blank address
			XMLValue += '<Address1></Address1>';
			XMLValue += '<Address2></Address2>';
			XMLValue += '<City></City><State></State><Zip5></Zip5><Zip4></Zip4>';
			
			// closing XML tags
			XMLValue += '</Address></AddressValidateResponse>';
			
		} else {
			// Default response . . . .
			// starting XML tags
			XMLValue = '<?xml version=\"1.0\"?><AddressValidateResponse><Address ID=\"0\">';
			
			// return the offical Test Request 1 from the USPS (with address1 added)
			XMLValue += '<Address1>Test</Address1>';
			XMLValue += '<Address2>6406 IVY LN</Address2>';
			XMLValue += '<City>GREENBELT</City><State>MD</State><Zip5>20770</Zip5><Zip4>1441</Zip4>';
			
			// closing XML tags
			XMLValue += '</Address></AddressValidateResponse>';
		} // IncomingRequest.contains('ERROR')
			
		ReturnValue.setBody(XMLValue);
		
		return ReturnValue;

	} // HTTPResponse Method
} // USPSHttpCalloutMock