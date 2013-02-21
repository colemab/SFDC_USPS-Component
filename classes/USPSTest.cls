public with sharing class USPSTest {

	// When this is set, it will trigger the lookup on the address to the USPS
	public string USPSUserIDCode {get; set;}

	public final Lead CurrentLead {get; set;}
	
	public USPSTest(ApexPages.StandardController stdController) {
		
		USPSUserIDCode = '';
		this.CurrentLead = (Lead)stdController.getRecord();
		
		CurrentLead.Street = '6406 Ivy Lane';
		CurrentLead.City = 'Greenbelt';
		CurrentLead.State = 'Md';
		CurrentLead.PostalCode = '20770';		
		
	} // constructor
	
	public pagereference validate() {
        
        // if the address validation hasn't been triggered, trigger it here
        if (USPSUserIDCode == '') {

			// Confirm you have an address before setting the code
			// without an address, the component won't actually do anything
			if (CurrentLead.Street != '' && CurrentLead.Street != null) {				
				if ((CurrentLead.PostalCode != '') || ((CurrentLead.City != '') && (CurrentLead.State != '')))  {
			        
			        USPSUserIDCode  = '<<<<<< INSERT YOUR ID HERE >>>>>>';
			        
			        return null;			
				} // have city and state OR Zip
								
			} // Address1 != ''
        	
        } // USPSUserIDCode == ''

		// Add any other form validation or save code here
		return null;
		         		
	} // validate
	
} // end class USPSTest