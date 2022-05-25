/*
    Purpose:
        When billing events are released this trigger creates line item schedules for
        timecard billing event items, expense billing event items and admin fee miscellaneous
        adjustment billing event items. It then associates the line item schedules with
        the timecards, expenses and miscellaneous adjustments
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    9/9/2015
*/
//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
trigger CreateLISOnBEIRelease on pse__Billing_Event__c (before update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('pse__Billing_Event__c')) return;	

    Set<Id> beIds = new Set<Id>();
    Set<Id> projectIds = new Set<Id>();
    for (pse__Billing_Event__c newBE : Trigger.new) {
        // Get only released billing events
        if (newBE.pse__Is_Released__c) {
            pse__Billing_Event__c oldBE = Trigger.oldMap.get(newBE.Id);
            if (!oldBE.pse__Is_Released__c) {
                beIds.add(newBE.Id);
                if (newBE.pse__Project__c != null) {
                    projectIds.add(newBE.pse__Project__c);
                }
            }
        }
    }

    if (!beIds.isEmpty()) {
        // The Line Item Schedules to be created require the project Contract and Invoice Billing Schedule
        Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>([
            select
                Id,
                Contract_ABC__c,
                Contract_ABC__r.Invoice_Billing_Schedule__c
            from pse__Proj__c
            where Id in :projectIds
        ]);

        // Get the billine event items for the released billing events
        List<pse__Billing_Event_Item__c> beis = [
            select
                pse__Amount__c,
                pse__Billing_Event__c,
                pse__Timecard_Split__c,
                pse__Expense__c,
                pse__Miscellaneous_Adjustment__c,
                pse__Category__c,
                pse__Project__c
            from pse__Billing_Event_Item__c
            where pse__Billing_Event__c in :beIds
        ];

        // Save the expense, miscellaneous adjustment and timecard ids for a subsequent query.
        Set<Id> expenseIds = new Set<Id>();
        Set<Id> miscAdjustmentIds = new Set<Id>();
        Set<Id> timecardIds = new Set<Id>();
        for (pse__Billing_Event_Item__c bei : beis) {
            if (bei.pse__Category__c.equals('Expense') && bei.pse__Expense__c != null) {
                expenseIds.add(bei.pse__Expense__c);
            }
            else if (bei.pse__Category__c.equals('Miscellaneous Adjustment') && bei.pse__Miscellaneous_Adjustment__c != null) {
                miscAdjustmentIds.add(bei.pse__Miscellaneous_Adjustment__c);
            }
            else if (bei.pse__Category__c.equals('Timecard') && bei.pse__Timecard_Split__c != null) {
                timecardIds.add(bei.pse__Timecard_Split__c);
            }
        }

        // The expenses, miscellaneous adjustments and timecards have a lookup to the Line Item Schedule, which must
        // be inserted before the lookup can be set. The association of the Line Item Schedule with the appropriate
        // expenses, miscellaneous adjustments or timecards is maintained with a GUID. The same GUID that keys the
        // Line Item Schedule also keys the expenses, miscellaneous adjustments or timecards.
        Map<String, Line_Item_Schedule__c> lisesByGUID = new Map<String, Line_Item_Schedule__c>();

        // Rollup expense amounts to the new Line Item Schedule
        Map<String, List<pse__Expense__c>> expensesByGUID = new Map<String, List<pse__Expense__c>>();
        if (!expenseIds.isEmpty()) {
            rollupExpenses(expenseIds, projects, beis, lisesByGUID, expensesByGUID);
        }

        // Rollup miscellaneous adjustment amounts to the new Line Item Schedule
        Map<String, List<pse__Miscellaneous_Adjustment__c>> misdAdjustmentsByGUID = new Map<String, List<pse__Miscellaneous_Adjustment__c>>();
        if (!miscAdjustmentIds.isEmpty()) {
            rollupMiscAdjustments(miscAdjustmentIds, projects, beis, lisesByGUID, misdAdjustmentsByGUID);
        }

        // Rollup timecard amounts to the new Line Item Schedule
        Map<String, List<pse__Timecard__c>> timecardsByGUID = new Map<String, List<pse__Timecard__c>>();
        if (!timecardIds.isEmpty()) {
            rollupTime(timecardIds, projects, beis, lisesByGUID, timecardsByGUID);
        }

        if (!lisesByGUID.isEmpty()) {
            List<pse__Expense__c> expensesToUpdate = new List<pse__Expense__c>();
            List<pse__Miscellaneous_Adjustment__c> miscAdjustmentsToUpdate = new List<pse__Miscellaneous_Adjustment__c>();
            List<pse__Timecard__c> timecardsToUpdate = new List<pse__Timecard__c>();
            insert lisesByGUID.values();
            for (String guid : lisesByGUID.keySet()) {
                // For each GUID, get the line item schedule
                Line_Item_Schedule__c lis = lisesByGUID.get(guid);

                if (expensesByGUID.containsKey(guid)) {
                    // If the GUID was for expenses ...
                    List<pse__Expense__c> expenseList = expensesByGUID.get(guid);
                    for (pse__Expense__c expense : expenseList) {
                        // Set the Line Item Schedule on the expense
                        expense.Line_Item_Schedule__c = lis.Id;
                        expensesToUpdate.add(expense);
                    }
                }
                else if (misdAdjustmentsByGUID.containsKey(guid)) {
                    // If the GUID was for miscellaneous adjustments ...
                    List<pse__Miscellaneous_Adjustment__c> maList = misdAdjustmentsByGUID.get(guid);
                    for (pse__Miscellaneous_Adjustment__c ma : maList) {
                        // Set the Line Item Schedule on the miscellaneous adjustment
                        ma.Line_Item_Schedule__c = lis.Id;
                        miscAdjustmentsToUpdate.add(ma);
                    }
                }
                else if (timecardsByGUID.containsKey(guid)) {
                    // If the GUID was for timecards ...
                    List<pse__Timecard__c> tcList = timecardsByGUID.get(guid);
                    for (pse__Timecard__c tc : tcList) {
                        // Set the line item schedule on the timecard
                        tc.Line_Item_Schedule__c = lis.Id;
                        timecardsToUpdate.add(tc);
                    }
                }
            }

            if (!expensesToUpdate.isEmpty()) update expensesToUpdate;
            if (!miscAdjustmentsToUpdate.isEmpty()) update miscAdjustmentsToUpdate;
            if (!timecardsToUpdate.isEmpty()) update timecardsToUpdate;
        }

    }

    /* 
     * Rollup expenses onto a new Line Item Schedule. The association between the schedule and the expenses
     * needs to be maintained until the schedules are inserted. This maintenance is accomplished using a
     * GUID to key both the schedule and the list of expenses.
     * Arguments:
     *      expenseIds - the ids of the expenses to be queried
     *      projects - the projects, with Contract and Billing Invoice Schedule
     *      beis - the billing event items
     *      lisesByGUID - the line item schedules to be later inserted
     *      expensesByGUID - the expenses to be later updated
     */
    private void rollupExpenses(Set<Id> expenseIds, 
                                Map<Id, pse__Proj__c> projects, 
                                List<pse__Billing_Event_Item__c> beis,
                                Map<String, Line_Item_Schedule__c> lisesByGUID,
                                Map<String, List<pse__Expense__c>> expensesByGUID) {
        // Query the expenses
        Map<Id, pse__Expense__c> expenses = new Map<Id, pse__Expense__c>([
            select
                Id,
                pse__Amount__c,
                Line_Item_Schedule__c
            from pse__Expense__c
            where Id in :expenseIds
        ]);

        // Group by billing event
        Map<Id, List<pse__Expense__c>> expensesByBE = new Map<Id, List<pse__Expense__c>>();
        for (pse__Billing_Event_Item__c bei : beis) {
            if (expenses.containsKey(bei.pse__Expense__c)) {
                pse__Expense__c expense = expenses.get(bei.pse__Expense__c);
                if (expensesByBE.containsKey(bei.pse__Billing_Event__c)) {
                        expensesByBE.get(bei.pse__Billing_Event__c).add(expense);
                }
                else {
                    List<pse__Expense__c> expenseList = new List<pse__Expense__c>();
                    expenseList.add(expense);
                    expensesByBE.put(bei.pse__Billing_Event__c, expenseList);
                }
            }
        }

        // Create the new Line Item Schedules
        for (Id beId : expensesByBE.keySet()) {
            pse__Billing_Event__c be = Trigger.newMap.get(beId);
            if (projects.containsKey(be.pse__Project__c)) {
                pse__Proj__c project = projects.get(be.pse__Project__c);
                List<pse__Expense__c> expenseList = expensesByBE.get(beId);
                Decimal amount = 0.0;
                for (pse__Expense__c expense : expenseList) {
                    amount += expense.pse__Amount__c;
                }

                Line_Item_Schedule__c lis = createLIS(project, amount, 'Travel T&M', 'Reimbursable Expenses');
                String guid = generateGUID();
                lisesByGUID.put(guid, lis);
                expensesByGUID.put(guid, expenseList);
            }
        }
    }

    /* 
     * Rollup miscellandous adjustments onto a new Line Item Schedule. The association between the schedule and the 
     * miscellaneous adjustments needs to be maintained until the schedules are inserted. This maintenance is accomplished 
     * using a GUID to key both the schedule and the list of miscellaneous adjustments.
     * Arguments:
     *      miscAdjustmentIds - the ids of the miscellaneous adjustments to be queried
     *      projects - the projects, with Contract and Billing Invoice Schedule
     *      beis - the billing event items
     *      lisesByGUID - the line item schedules to be later inserted
     *      expensesByGUID - the miscellaneous adjustments to be later updated
     */
    private void rollupMiscAdjustments(Set<Id> miscAdjustmentIds, 
                                       Map<Id, pse__Proj__c> projects, 
                                       List<pse__Billing_Event_Item__c> beis,
                                       Map<String, Line_Item_Schedule__c> lisesByGUID,
                                       Map<String, List<pse__Miscellaneous_Adjustment__c>> miscAdjustmentsByGUID) {
        // Query the miscellaneous adjustments
        Map<Id, pse__Miscellaneous_Adjustment__c> miscAdjustments = new Map<Id, pse__Miscellaneous_Adjustment__c>([
            select
                Id,
                pse__Amount__c,
                Line_Item_Schedule__c
            from pse__Miscellaneous_Adjustment__c
            where 
                Id in :miscAdjustmentIds and 
                pse__Transaction_Category__c = 'Ready-to-Bill Revenue'
        ]);
        
        if (!miscAdjustments.isEmpty()) {
            // Group by billing event
            Map<Id, List<pse__Miscellaneous_Adjustment__c>> miscAdjustmentsByBE = new Map<Id, List<pse__Miscellaneous_Adjustment__c>>();
            for (pse__Billing_Event_Item__c bei : beis) {
                if (miscAdjustments.containsKey(bei.pse__Miscellaneous_Adjustment__c)) {
                    pse__Miscellaneous_Adjustment__c miscAdjustment = miscAdjustments.get(bei.pse__Miscellaneous_Adjustment__c);
                    if (miscAdjustmentsByBE.containsKey(bei.pse__Billing_Event__c)) {
                            miscAdjustmentsByBE.get(bei.pse__Billing_Event__c).add(miscAdjustment);
                    }
                    else {
                        List<pse__Miscellaneous_Adjustment__c> maList = new List<pse__Miscellaneous_Adjustment__c>();
                        maList.add(miscAdjustment);
                        miscAdjustmentsByBE.put(bei.pse__Billing_Event__c, maList);
                    }
                }
            }

            // Create the new line item schedules
            for (Id beId : miscAdjustmentsByBE.keySet()) {
                pse__Billing_Event__c be = Trigger.newMap.get(beId);
                if (projects.containsKey(be.pse__Project__c)) {
                    pse__Proj__c project = projects.get(be.pse__Project__c);
                    List<pse__Miscellaneous_Adjustment__c> maList = miscAdjustmentsByBE.get(beId);
                    Decimal amount = 0.0;
                    for (pse__Miscellaneous_Adjustment__c miscAdjustment : maList) {
                        amount += miscAdjustment.pse__Amount__c;
                    }

                    Line_Item_Schedule__c lis = createLIS(project, amount, 'Admin Fee', 'Administrative Fee');
                    String guid = generateGUID();
                    lisesByGUID.put(guid, lis);
                    miscAdjustmentsByGUID.put(guid, maList);
                }
            }
        }
    }

    /* 
     * Rollup timecards onto a new Line Item Schedule. The association between the schedule and the timecards
     * needs to be maintained until the schedules are inserted. This maintenance is accomplished using a
     * GUID to key both the schedule and the list of timecards.
     * Arguments:
     *      timecardIds - the ids of the timecards to be queried
     *      projects - the projects, with Contract and Billing Invoice Schedule
     *      beis - the billing event items
     *      lisesByGUID - the line item schedules to be later inserted
     *      expensesByGUID - the timecards to be later updated
     */
    private void rollupTime(Set<Id> timecardIds, 
                            Map<Id, pse__Proj__c> projects, 
                            List<pse__Billing_Event_Item__c> beis,
                            Map<String, Line_Item_Schedule__c> lisesByGUID,
                            Map<String, List<pse__Timecard__c>> timecardsByGUID) {
        // Query the timecards
        Map<Id, pse__Timecard__c> timecards = new Map<Id, pse__Timecard__c>([
            select
                Id,
                pse__Total_Billable_Amount__c,
                Line_Item_Schedule__c
            from pse__Timecard__c
            where Id in :timecardIds
        ]);

        // Group by billing event
        Map<Id, List<pse__Timecard__c>> timecardsByBE = new Map<Id, List<pse__Timecard__c>>();
        for (pse__Billing_Event_Item__c bei : beis) {
            if (timecards.containsKey(bei.pse__Timecard_Split__c)) {
                pse__Timecard__c timecard = timecards.get(bei.pse__Timecard_Split__c);
                if (timecardsByBE.containsKey(bei.pse__Billing_Event__c)) {
                        timecardsByBE.get(bei.pse__Billing_Event__c).add(timecard);
                }
                else {
                    List<pse__Timecard__c> tcList = new List<pse__Timecard__c>();
                    tcList.add(timecard);
                    timecardsByBE.put(bei.pse__Billing_Event__c, tcList);
                }
            }
        }

        // Create the new line item schedules
        for (Id beId : timecardsByBE.keySet()) {
            pse__Billing_Event__c be = Trigger.newMap.get(beId);
            if (projects.containsKey(be.pse__Project__c)) {
                pse__Proj__c project = projects.get(be.pse__Project__c);
                List<pse__Timecard__c> tcList = timecardsByBE.get(beId);
                Decimal amount = 0.0;
                for (pse__Timecard__c tc : tcList) {
                    amount += tc.pse__Total_Billable_Amount__c;
                }

                Line_Item_Schedule__c lis = createLIS(project, amount, 'Billable Time', 'Professional Fees (see attached)');
                String guid = generateGUID();
                lisesByGUID.put(guid, lis);
                timecardsByGUID.put(guid, tcList);
            }
        }
    }

    /* 
     * Create a new line item schedule
     */
    private Line_Item_Schedule__c createLIS(pse__Proj__c project, Decimal amount, String type, String comment) {
        Line_Item_Schedule__c lis = new Line_Item_Schedule__c(
            Contract__c = project.Contract_ABC__c,
            Invoice_Billing_Schedule_del__c = project.Contract_ABC__r.Invoice_Billing_Schedule__c,
            Type__c = type,
            Invoice_Amount__c = amount,
            Invoice_Date__c = Date.today(),
            Invoice_Comment__c = null,
            Line_Item_Comment__c = comment,
            Invoiced__c = false
        );

        return lis;
    }

    /* 
     * Create a GUID
     */
    private String generateGUID() {
        String kHexChars = '0123456789abcdefABCDEF';
        String returnValue ='';
        Integer nextByte = 0;
        for(Integer i = 0; i < 16; i++){
            if(i==4 || i==6 || i==8 || i==10){
                returnValue += '-';
            }
 
            nextByte = (Math.round(Math.random() * 255)-128) & 255;
 
            if(i==6){
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }
        return returnValue;
    }
 
    /* 
     * Get a specific character. This is a helper method for generateGUID.
     */
    public static String getCharAtIndex(String str, Integer index) {
        if(str == null){
            return null;
        }
        if(str.length() <= 0){
            return str;
        }
        if(index == str.length()){
            return null;
        }
        return str.substring(index, index+1);
    }
}