/**
 *  Purpose         :	Batch job executed when Institution is inserted or certain fields are updated.  Gets the Lat/Lon and timezone info
 *
 *  Revision Logs   :	V_1.0 - 07/13/2020 - CR-20200706-14269 - Victor Hanson - Created
 * 
**/
global class Batch_GeocodeAddress implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {
	
    global String qryString;
    
    global database.querylocator start(database.batchableContext bc) {
        if (qryString == null)
            qryString = 'SELECT Id, Primary_Address_Line_1__c, '
            			+ 'Primary_City__c, Primary_Postal_Code__c, Primary_State_Province__c, Primary_Country__c, '
            			+ 'Primary_Location__Latitude__s, Primary_Location__Longitude__s, Time_Zone_ID__c, Time_Zone_Name__c, Geolocation_Status__c '
            			+ ' FROM Account WHERE Geolocation_Status__c = \'' + LocationHelper.READY_FOR_BATCH + '\'';
        
        //limit number of records to process if this is a sandbox
        if (SessionHelper.isSandbox())
            qryString += ' LIMIT 5';
        return database.getquerylocator(qryString);
    }
    
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        list<Account> accts = (list<Account>) sc;
        List<Web_Service_Log__c> wsLogs = new List<Web_Service_Log__c>();
        
        for (Account acct : accts) {
            LocationHelper lHelper = new LocationHelper();
            lHelper.acctId = acct.Id;
            List<String> listAddressParts = new List<String>();
            listAddressParts.add(EncodingUtil.urlEncode(acct.Primary_Address_Line_1__c, 'UTF-8'));
            if (acct.Primary_City__c != null) 
                listAddressParts.add(EncodingUtil.urlEncode(acct.Primary_City__c, 'UTF-8'));
            if (acct.Primary_State_Province__c != null && (LocationHelper.listCountryWithStates.contains(acct.Primary_Country__c))) 
                listAddressParts.add(EncodingUtil.urlEncode(acct.Primary_State_Province__c, 'UTF-8'));
            if (acct.Primary_Postal_Code__c != null) 
                listAddressParts.add(EncodingUtil.urlEncode(acct.Primary_Postal_Code__c, 'UTF-8'));
            //put the pieces of the address into comma-delimited format
            String urlEncodedAddress = String.join(listAddressParts, ',');
            
            try {
                //executes the callout to get geolocation info
                SearchAddressWrapper addressWrapper = lHelper.getGeolocation(urlEncodedAddress);
                
                //check if the lat/lon was returned
                if (addressWrapper != null && 
                    addressWrapper.results != null && 
                    addressWrapper.results.size() > 0 &&
                    addressWrapper.results[0].position != null && 
                    addressWrapper.results[0].position.lat != null && 
                    addressWrapper.results[0].position.lon != null) 
                {
                    acct.Geolocation_Status__c = LocationHelper.COMPLETED_SUCCESS;
                    acct.Primary_Location__Latitude__s = addressWrapper.results[0].position.lat;
                    acct.Primary_Location__Longitude__s = addressWrapper.results[0].position.lon;
                }
                else {
                    acct.Geolocation_Status__c = LocationHelper.COMPLETED_FAIL;
                }
                
                //if the lat/lon was received successfully, get the timezone info
                if (acct.Geolocation_Status__c == LocationHelper.COMPLETED_SUCCESS) {
                    //executes the timezone callout
                    SearchTimezoneWrapper timezoneWrapper = lHelper.getTimezone(acct.Primary_Location__Latitude__s + ',' + acct.Primary_Location__Longitude__s);
                    //check if the timezone was returned
                    if (timezoneWrapper != null && 
                        timezoneWrapper.timezones != null && 
                        timezoneWrapper.timezones.size() > 0 &&
                        timezoneWrapper.timezones[0].Id != null && 
                        timezoneWrapper.timezones[0].Names != null && 
                        timezoneWrapper.timezones[0].Names.Generic != null) 
                    {
                        acct.Geolocation_Status__c = LocationHelper.COMPLETED_SUCCESS;
                        acct.Time_Zone_ID__c = timezoneWrapper.timezones[0].Id;
                        acct.Time_Zone_Name__c = timezoneWrapper.timezones[0].Names.Generic;
                    }
                    else {
                        acct.Geolocation_Status__c = LocationHelper.COMPLETED_FAIL;
                    }
                }
                
            }
            catch (Exception e) {
                acct.Geolocation_Status__c = LocationHelper.COMPLETED_FAIL;
            }
            
            //add all web service logs
            wsLogs.addAll(lHelper.wsLogs);
        }
        
        //bypass triggers before updating accounts
        util.bypassAllTriggers = true;
        
        //update accounts
        database.update(accts, false);
        
        //insert web service logs
        if (wsLogs.size() > 0)
            database.insert(wsLogs, false);
    }
    
    
    global void finish(database.batchableContext bc) {
        
    }
}