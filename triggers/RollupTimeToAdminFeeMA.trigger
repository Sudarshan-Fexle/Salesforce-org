/*
    Purpose:
        When an timecard split is created, updated or deleted, this trigger rolls-up the time on all
        timecard splits to a miscellaneous adjustment on the project. The miscellaneous adjustment selected
        for the rollup is the one whose effective date is at the end of the time period in which the 
        timecard split occurs. It rolls up time only for approved timecards that are on the following types of projects:
            - pse__Billing_Type__c = Time and Materials
            - Admin_Fee__c > 0.0
            - Admin_Fee_Incl_in_Bill_Rate__c = false
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    8/17/2015
    Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*/

trigger RollupTimeToAdminFeeMA on pse__Timecard__c (before insert, before update, after update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('pse__Timecard__c')) return;	

    if (Trigger.isInsert) {
        System.debug('&&&&& RollupTimeToAdminFeeMA trigger insert');

        List<pse__Timecard__c> approvedTimecards = new List<pse__Timecard__c>();
        Set<Id> projectIds = new Set<Id>();
        for (pse__Timecard__c timecard : Trigger.new) {
            if (timecard.pse__Approved__c) {
                approvedTimecards.add(timecard);
                projectIds.add(timecard.pse__Project__c);
            }
        }

        if (!approvedTimecards.isEmpty()) {
            // Include only T&M projects with non-zero Admin Fee and Admin Fee Incl in Bill Rate? = false
            Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>([
                select
                    Id,
                    pse__Billing_Type__c
                from pse__Proj__c
                where 
                    Id in :projectIds and 
                    pse__Billing_Type__c = 'Time and Materials' and 
                    Admin_Fee__c > 0.0 and 
                    Admin_Fee_Incl_in_Bill_Rate__c = false
            ]);

            if (!projects.isEmpty()) {
                // Exclude timecards not in the projects
                List<pse__Timecard__c> approvedTMTimecards = new List<pse__Timecard__c>();
                for (pse__Timecard__c timecard : approvedTimecards) {
                    if (projects.containsKey(timecard.pse__Project__c)) {
                        approvedTMTimecards.add(timecard);
                    }
                }
                RollupTimeToAdminFeeHelper rollupHelper = new RollupTimeToAdminFeeHelper(approvedTMTimecards, projects.keySet());
                rollupHelper.rollupTime();
            }
        }
    }
    else if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            System.debug('&&&&& RollupTimeToAdminFeeMA trigger update before');
            
            List<pse__Timecard__c> approvedTimecards = new List<pse__Timecard__c>();
            List<pse__Timecard__c> approvedModifiedTimecards = new List<pse__Timecard__c>();
            List<pse__Timecard__c> unapprovedTimecards = new List<pse__Timecard__c>();
            Set<Id> projectIds = new Set<Id>();
            for (pse__Timecard__c newTimecard : Trigger.new) {
                pse__Timecard__c oldTimecard = Trigger.oldMap.get(newTimecard.Id);
                if (newTimecard.pse__Approved__c) {
                    if (!oldTimecard.pse__Approved__c) {
                        approvedTimecards.add(newTimecard);
                        projectIds.add(newTimecard.pse__Project__c);
                    }
                    else if (newTimecard.pse__Total_Hours__c != oldTimecard.pse__Total_Hours__c) {
                        approvedModifiedTimecards.add(newTimecard);
                        projectIds.add(newTimecard.pse__Project__c);
                    }
                }
                else {
                    if (oldTimecard.pse__Approved__c) {
                        unapprovedTimecards.add(newTimecard);
                        projectIds.add(oldTimecard.pse__Project__c);
                    }
                }
            }

            if (!projectIds.isEmpty()) {
                // Include only T&M projects with non-zero Admin Fee and Admin Fee Incl in Bill Rate? = false
                Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>([
                    select
                        Id,
                        pse__Billing_Type__c
                    from pse__Proj__c
                    where 
                        Id in :projectIds and 
                        pse__Billing_Type__c = 'Time and Materials' and 
                        Admin_Fee__c > 0.0 and 
                        Admin_Fee_Incl_in_Bill_Rate__c = false
                ]);

                if (!projects.isEmpty()) {
                    // Exclude timecards not in the projects

                    List<pse__Timecard__c> approvedTMTimecards = new List<pse__Timecard__c>();
                    for (pse__Timecard__c timecard : approvedTimecards) {
                        if (projects.containsKey(timecard.pse__Project__c)) {
                            approvedTMTimecards.add(timecard);
                        }
                    }

                    List<pse__Timecard__c> approvedModifiedTMTimecards = new List<pse__Timecard__c>();
                    for (pse__Timecard__c timecard : approvedModifiedTimecards) {
                        if (projects.containsKey(timecard.pse__Project__c)) {
                            approvedModifiedTMTimecards.add(timecard);
                        }
                    }

                    List<pse__Timecard__c> unapprovedTMTimecards = new List<pse__Timecard__c>();
                    for (pse__Timecard__c timecard : unapprovedTimecards) {
                        if (projects.containsKey(timecard.pse__Project__c)) {
                            unapprovedTMTimecards.add(timecard);
                        }
                    }

                    RollupTimeToAdminFeeHelper rollupHelper = new RollupTimeToAdminFeeHelper(approvedTMTimecards, approvedModifiedTMTimecards, unapprovedTMTimecards, projects.keySet());
                    rollupHelper.rollupTime();
                }
            }
        }
        else {
            if (!RollupTimeToAdminFeeHelper.orphanedMAs.isEmpty()) {
                delete RollupTimeToAdminFeeHelper.orphanedMAs;
                RollupTimeToAdminFeeHelper.orphanedMAs.clear();
            }
        }
    }
}