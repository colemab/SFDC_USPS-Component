This is an example component for use on the Salesforce.com platform for 
validating an address on the lead object against the USPS's e-commerce 
address standardization API.

A great use for this would be on a custom web2lead visual force page.

This component uses jquery, jquery ui (with lightness css), and jquery block ui.
These libraries are loaded via the CDN's listed below.

Please note: you will need to have a valid account with access to the
API to use this component.

Please note: you will need to add a remote site under security settings so that the component
can connect to the post office.  For production this will be: http://production.shippingapis.com

Links:

Blog write-up with example: http://www.forcedisturbances.com/2012/10/vf-component-for-usps-address.html

E-Commerice APIs: https://www.usps.com/business/webtools.htm
Address Info API: https://www.usps.com/business/webtools-address-information.htm?
Web Tools User Guide: https://www.usps.com/webtools/_pdf/Address-Information-v3-1b.pdf

Externally referenced resources:

http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
http://cachedcommons.org/cache/jquery-blockui/2.3.3/javascripts/jquery-blockui-min.js
http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.9/jquery-ui.min.js
http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/themes/ui-lightness/jquery-ui.css