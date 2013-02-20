public with sharing class USPS {	
	
	private static string BuildAddressQueryURLString(USPSAddress AddressToQuery, string USPS_UID) { 
				
		// this function is coded to send only one address at a time
		// but it could be updated to support more (10 is the max ATM) by
		// iterating over addresses and incremending the address ID XML for each address 
		// until you have one large URL as your query.
		
		// However, if you do modify this for mutiple addresses then you will need to
		// re-write the XML parse to handle that as well.  
		
		String BaseURL = 'http://production.shippingapis.com/ShippingAPI.dll?API=Verify&XML=';
		String ReturnValue = '<AddressValidateRequest USERID="' + USPS_UID + '"><Address ID="0">';
		
		ReturnValue += '<Address1>' + AddressToQuery.Address1 + '</Address1>';
		ReturnValue += '<Address2>' + AddressToQuery.Address2 + '</Address2>';
		ReturnValue += '<City>' + AddressToQuery.City + '</City>';
		ReturnValue += '<State>' + AddressToQuery.State + '</State>';
		ReturnValue += '<Zip5>' + AddressToQuery.Zip5 + '</Zip5>';
		ReturnValue += '<Zip4>' + AddressToQuery.Zip4 + '</Zip4>';		
		ReturnValue += '</Address></AddressValidateRequest>';
		
		ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
		
		ReturnValue = BaseURL + ReturnValue; 
		
		return ReturnValue;
		
	} // BuildAddressQueryURLString

	private static string GetStandardizedAddressFromUSPS(string USPSURLtoQuery) {

			 string ReturnValue = '';

			// winter 13 added support for testing http callouts via a mock class
			// if you are not running this on winter 13 or later you will need
			// to modify your code to get test coverage
			 if (Test.IsRunningTest()) {
				 Test.setMock(HttpCalloutMock.class, new USPSHttpCalloutMock());
			 }			 
			 
	         HttpRequest USPSRequest = new HttpRequest();
	         Http USPSHttp = new Http();
	         
	         USPSRequest.setMethod('GET');
	         
	         USPSRequest.setEndpoint(USPSURLtoQuery);

             HttpResponse USPSResponse = USPSHttp.send(USPSRequest);
             ReturnValue = USPSResponse.getBody();  
		
			 system.debug('XML Response was: ' + ReturnValue);
			 system.debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
			 
			 return ReturnValue;
		
	} // GetStandardizedAddressFromUSPS
	
	private static USPSAddress ParseUSPSResponseXML(String XMLToParse) {
		USPSAddress ReturnAddress = new USPSAddress();

		// parse the response
		XMLStreamReader USPSXMLReader = new XMLStreamReader(XMLToParse);
		
		while (USPSXMLReader.hasNext()) {

	         if (USPSXMLReader.getEventType() == XmlTag.START_ELEMENT) {

	            if ('AddressValidateResponse' == USPSXMLReader.getLocalName()) {
	            		            	
	            	USPSXMLReader.next();
	            	
		            if ('Address' == USPSXMLReader.getLocalName()) {
		            	ReturnAddress = ParseUSPSAddressXML(USPSXMLReader);
		            } // <Address ID="0"> tag
		            
	            } // <AddressValidateResponse> confirmation
	         } // Starting tag        
			
			USPSXMLReader.next();
	         		
		} // loop thru UPS XML Reader

		if (ReturnAddress.HasData() == false) {
			// if parsing comes back totally blank then indicate an unknown / parsing error to the caller / requestor
			system.Debug('ReturnAddress.HasData() == false');
			ReturnAddress.USPS_Returned_Error = true;
			ReturnAddress.USPS_ERROR_DESC = 'Unknown Error parsing XML Response';
			ReturnAddress.USPS_ERROR_SOURCE = 'Salesforce XML Parsing';
			ReturnAddress.USPS_ERROR_CODE = '-1';
		} // ReturnAddress.HasData() == false

		return ReturnAddress;
	} // ParseAddressXML
	
	private static USPSAddress ParseUSPSAddressXML(XMLStreamReader USPSAddressXMLReader) {
		USPSAddress ReturnAddress = new USPSAddress();
		
		while(USPSAddressXMLReader.hasNext()) {
	        if (USPSAddressXMLReader.getEventType() == XmlTag.END_ELEMENT) {
	        	if ('Address' == USPSAddressXMLReader.getLocalName()) {
	        		// quit parsing when we hit the end of this record	        	
		           break;
	        	} // check for address ending tag
	        } else if ('Error' == USPSAddressXMLReader.getLocalName()) {
	        	system.Debug('API Returned an error!');
	        	
	        	ReturnAddress = ParseUSPSErrorXML(USPSAddressXMLReader);
	        	ReturnAddress.USPS_Returned_Error = true;
	        } else if ('Address1' == USPSAddressXMLReader.getLocalName()) {
	        	
	        	USPSAddressXMLReader.next();
	        	
	        	if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('Address1: ' +  USPSAddressXMLReader.getText());	        	
        			ReturnAddress.Address1 = USPSAddressXMLReader.getText();
	        	} // check for data
	        } else if ('Address2' == USPSAddressXMLReader.getLocalName()) {
	        	
	        	USPSAddressXMLReader.next();
	        	
	        	if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('Address2: ' +  USPSAddressXMLReader.getText());	        	
	        		ReturnAddress.Address2 = USPSAddressXMLReader.getText();
	        	} // check for data
	        } else if ('City' == USPSAddressXMLReader.getLocalName()) {
	        	
	        	USPSAddressXMLReader.next();
	        	
	        	if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('City: ' +  USPSAddressXMLReader.getText());	        	
	        		ReturnAddress.City = USPSAddressXMLReader.getText();
	        	} // check for data
	        } else if ('State' == USPSAddressXMLReader.getLocalName()) {
	        	
	        	USPSAddressXMLReader.next();
	        	
	        	if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('State: ' +  USPSAddressXMLReader.getText());	        	
	        		ReturnAddress.State = USPSAddressXMLReader.getText();
	        	} // check for data
	        } else if ('Zip5' == USPSAddressXMLReader.getLocalName()) {
	        	
	        	USPSAddressXMLReader.next();
	        	
	        	if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('Zip5: ' +  USPSAddressXMLReader.getText());	        	
	        		ReturnAddress.Zip5 = USPSAddressXMLReader.getText();
	        	} // check for data
	        } else if ('Zip4' == USPSAddressXMLReader.getLocalName()) {
	        	
	        	USPSAddressXMLReader.next();
	        	
	        	if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('Zip4: ' +  USPSAddressXMLReader.getText());	        	
	        		ReturnAddress.Zip4 = USPSAddressXMLReader.getText();
	        	} // check for data
	        	        		        	
	        } // check for end tags
	        
	        USPSAddressXMLReader.next();
	        
	     } // loop thru XML reader
		
		return ReturnAddress;		
	} // ParseUSPSAddressXML
	
	private static USPSAddress ParseUSPSErrorXML(XMLStreamReader USPSErrorXMLReader) {

		USPSAddress ReturnAddress = new USPSAddress();
		
		while(USPSErrorXMLReader.hasNext()) {
	        if (USPSErrorXMLReader.getEventType() == XmlTag.END_ELEMENT) {
	        	if ('Error' == USPSErrorXMLReader.getLocalName()) {
		        	// quit parsing when we hit the end of this record
		           	break;
	        	}
	        } else if ('Number' == USPSErrorXMLReader.getLocalName()) {
	        	
	        	USPSErrorXMLReader.next();
	        	
	        	if (USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('Error Number / Code: ' +  USPSErrorXMLReader.getText());	        	
	        		ReturnAddress.USPS_ERROR_CODE = USPSErrorXMLReader.getText();
	        	} // check for data
	        } else if ('Source' == USPSErrorXMLReader.getLocalName()) {
	        	
	        	USPSErrorXMLReader.next();
	        	
	        	if (USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('Error Source: ' + USPSErrorXMLReader.getText());	        	
	        		ReturnAddress.USPS_ERROR_SOURCE = USPSErrorXMLReader.getText();
	        	} // check for data
	        } else if ('Description' == USPSErrorXMLReader.getLocalName()) {
	        	
	        	USPSErrorXMLReader.next();
	        	
	        	if (USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {
	        		system.Debug('Error Description: ' + USPSErrorXMLReader.getText());	        	
	        		ReturnAddress.USPS_ERROR_DESC = USPSErrorXMLReader.getText();
	        	} // check for data
	        	
	        } // check for ending element
	        
	        USPSErrorXMLReader.next();
	        
	     } // loop thru XML reader
		
		return ReturnAddress;		

		
	} // ParseUSPSErrorXML
	
	public static USPSAddress CheckAddress(USPSAddress Address2Check, string USERID) {

		USPSAddress ResponseAddress = new USPSAddress();
		
		// build the URL for the API call		
		string USPSURL = BuildAddressQueryURLString(Address2Check, USERID);

		// call the API and pullback the XML as a string
		string XMLResponse = GetStandardizedAddressFromUSPS(USPSURL);
		
		// send the XML reponse to the parser
		ResponseAddress = ParseUSPSResponseXML(XMLResponse);
		
		/*
		system.debug('-=-=-=-=-=-=- Results -=-=-=-=-=-=-');
		system.debug('Address1: ' + ResponseAddress.Address1);
		system.debug('Address2: ' + ResponseAddress.Address2);
		system.debug('City: ' + ResponseAddress.City);
		system.debug('State: ' + ResponseAddress.State);
		system.debug('Zip5: ' + ResponseAddress.Zip5);
		system.debug('Zip4: ' + ResponseAddress.Zip4);
		
		if (ResponseAddress.USPS_Returned_Error == true) {
			system.debug('USPS_ERROR_CODE: ' + ResponseAddress.USPS_ERROR_CODE);
			system.debug('USPS_ERROR_DESC: ' + ResponseAddress.USPS_ERROR_DESC);
			system.debug('USPS_ERROR_SOURCE: ' + ResponseAddress.USPS_ERROR_SOURCE);
		} // check for error code
		
		system.debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');		
		
		system.debug('-=-=-=-=-=-=- Searched -=-=-=-=-=-=-');
		system.debug('Address1: ' + Address2Check.Address1);
		system.debug('Address2: ' + Address2Check.Address2);
		system.debug('City: ' + Address2Check.City);
		system.debug('State: ' + Address2Check.State);
		system.debug('Zip5: ' + Address2Check.Zip5);
		system.debug('Zip4: ' + Address2Check.Zip4);
		system.debug('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');		
		*/
		
		return ResponseAddress;
		
	} // CheckAddress
	
	static testMethod void TestUSPS() {
	
		Test.StartTest();
		
		USPSAddress MyAddress = new USPSAddress();
		
		// will return the default address		
		USPS.CheckAddress(MyAddress,'Test');
		
		// This should return an error message
		MyAddress.City = 'ERROR';
		USPS.CheckAddress(MyAddress,'Test');

		// and this shoudl return a blank address 
		// so we can test the generic error message
		MyAddress.City = 'NULL';
		USPS.CheckAddress(MyAddress,'Test');
		
		Test.StopTest();
	} // TestUSPS
	
} // end USPS Class