@isTest
private class TestMultiSelectPicklistController {
    public static testMethod void testController()
	{
		Restrictions__c restriction = new Restrictions__c();
		restriction.Reason__c = 'Large Renewal';
		restriction.Category__c = 'Restricted: Permission Required';
		restriction.Name = 'Restricted: Permission Required';
		restriction.Source_Department__c = 'Chairman\'s Team';
		restriction.Expiration_Date__c = system.today().addDays(+10);
		insert restriction;	
		
		MultiSelectPicklistController mspc = new MultiSelectPicklistController();
        System.assert(!mspc.IsRequired);
        System.assertEquals('5', mspc.Size);
        
		mspc.PickerType = 'RestrictionReason';
		mspc.TargetObject = restriction;
		mspc.TargetField = 'Reason__c';
		
		// Make sure the correct reason is selected.
		boolean bSelectedItemFound = false;
		for(SelectOption opt : mspc.getSelectedValues())
		{
			if(opt.getValue() == restriction.Reason__c)
				bSelectedItemFound = true;
		}
		System.assertEquals(true,bSelectedItemFound);
		System.assertEquals('Large Renewal',restriction.Reason__c);
		
		// Simulate unselecting a value
		mspc.rightselected.add(restriction.Reason__c);
		mspc.unselectClick();
		// Check that the value is back in the unselected column
		bSelectedItemFound = false;
		for(SelectOption opt : mspc.getUnSelectedValues())
		{
			if(opt.getValue() == 'Large Renewal')
				bSelectedItemFound = true;
		}
		System.assertEquals(true,bSelectedItemFound);
		System.assertEquals('',restriction.Reason__c);
		
		// Check that we can re-select it.
		mspc.leftselected.add('Large Renewal');
		mspc.selectClick();
		bSelectedItemFound = false;
		for(SelectOption opt : mspc.getSelectedValues())
		{
			if(opt.getValue() == 'Large Renewal')
				bSelectedItemFound = true;
		}
		System.assertEquals(true,bSelectedItemFound);
		System.assertEquals('Large Renewal;',restriction.Reason__c);
	}
	
	public static testMethod void testController_ExternalData()
	{
		SFDC_Change_Request__c changeReqest = new SFDC_Change_Request__c();
		changeReqest.Title__c = 'test';
		insert changeReqest;
		
		List<String> names = new List<String>();
		List<User> users = [SELECT Name FROM User LIMIT 5000];
		for (User u : users) {
			names.add(u.Name);
		}
		
		MultiSelectPicklistController mspc = new MultiSelectPicklistController();
		mspc.TargetData = names;
		mspc.PickerType = 'TeamInvolved';
		mspc.TargetObject = changeReqest;
		mspc.TargetField = 'IS_Team_Involved__c';
		
		mspc.Init();
		
		system.assertNotEquals(null, mspc.FormattedData);
		system.assert(mspc.leftvalues.size() > 5);
	}
    
    public static testMethod void testController_EmptyFieldDescribeMap()
	{
        system.assert(MultiSelectPicklistController.GetFieldDescribeMap(null) == null);
        system.assert(MultiSelectPicklistController.cachedDescribes == null);
    }
}