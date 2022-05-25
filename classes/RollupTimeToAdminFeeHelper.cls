/*
    Purpose:
        The helper class for the RollupTimeToAdminFeeMA trigger
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    8/17/2015
*/

public with sharing class RollupTimeToAdminFeeHelper {

    public static List<pse__Miscellaneous_Adjustment__c> orphanedMAs = new List<pse__Miscellaneous_Adjustment__c>();
    public static boolean hasBeenRolledUp = false;

    private List<pse__Miscellaneous_Adjustment__c> newMAs;
    private List<pse__Miscellaneous_Adjustment__c> modifiedMAs;

    private List<pse__Timecard__c> newlyApprovedTimecards;
    private List<pse__Timecard__c> approvedModifiedTimecards;
    private List<pse__Timecard__c> newlyUnapprovedTimecards;
    private List<pse__Timecard__c> existingTimecards;
    private Map<Id, pse__Assignment__c> assignments;

    private Set<Id> triggerTimecardIds;

    private Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>> existingMAsByProjectAndDate;
    private Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>> rolledUpMAsByProjectAndDate;
    private Map<Id, Map<Id, pse__Miscellaneous_Adjustment__c>> billedMAsByProject;

    private Map<Id, pse__Miscellaneous_Adjustment__c> miscAdjustments;

    private final Map<Integer, String> months = new Map<Integer, String>{
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        12 => 'Dec'
    };

    /*
     * The constructor for insertion of new timecards
     */
    public RollupTimeToAdminFeeHelper(List<pse__Timecard__c> approvedTimecards, Set<Id> projectIds) {
        this.newMas = new List<pse__Miscellaneous_Adjustment__c>();
        this.modifiedMAs = new List<pse__Miscellaneous_Adjustment__c>();
        this.newlyApprovedTimecards = approvedTimecards;
        this.approvedModifiedTimecards = new List<pse__Timecard__c>();
        this.newlyUnapprovedTimecards = new List<pse__Timecard__c>();
        this.existingMAsByProjectAndDate = new Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>>();
        this.rolledUpMAsByProjectAndDate = new Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>>();
        this.billedMAsByProject = new Map<Id, Map<Id, pse__Miscellaneous_Adjustment__c>>();
        this.triggerTimecardIds = new Set<Id>();

        Set<Id> newTCAssignmentIds = new Set<Id>();
        for (pse__Timecard__c newTimecard : this.newlyApprovedTimecards) {
            if (newTimecard.pse__Assignment__c != null) {
                newTCAssignmentIds.add(newTimecard.pse__Assignment__c);
            }
        }

        List<pse__Miscellaneous_Adjustment__c> miscAdjustments = [
            select
                Id,
                pse__Amount__c,
                pse__Billing_Event__c,
                pse__Billed__c,
                pse__Project__c,
                pse__Effective_Date__c
            from pse__Miscellaneous_Adjustment__c
            where pse__Project__c in :projectIds
        ];

        System.debug('&&&&& queried ' + miscAdjustments.size() + ' misc adjustments');

        separateMAsIntoBilledAndNonBilled(miscAdjustments);

        this.existingTimecards = [
            select
                pse__Project__c,
                pse__Start_Date__c,
                pse__End_Date__c,
                pse__Total_Hours__c,
                pse__Approved__c,
                pse__Assignment__c,
                pse__Assignment__r.pse__Bill_Rate__c
            from pse__Timecard__c
            where 
                pse__Project__c in :projectIds and
                pse__Approved__c = true
        ];

        Set<Id> oldTCAssignmentIds = new Set<Id>();
        for (pse__Timecard__c timecard : this.existingTimecards) {
            if (timecard.pse__Assignment__c != null) {
                oldTCAssignmentIds.add(timecard.pse__Assignment__c);
            }
        }

        this.assignments = new Map<Id, pse__Assignment__c>([
            select 
                Id, 
                pse__Bill_Rate__c,
                pse__Project__c,
                pse__Project__r.Admin_Fee__c
            from pse__Assignment__c
            where 
                Id in :newTCAssignmentIds or
                Id in :oldTCAssignmentIds
        ]);
    }

    /*
     * The constructor for timecard updates, when a timecard is approved, unapproved or its hours modified.
     */
    public RollupTimeToAdminFeeHelper(List<pse__Timecard__c> approvedTimecards, 
                                      List<pse__Timecard__c> approvedModifiedTimecards,
                                      List<pse__Timecard__c> unapprovedTimecards,
                                      Set<Id> projectIds) {
        this.newMas = new List<pse__Miscellaneous_Adjustment__c>();
        this.modifiedMAs = new List<pse__Miscellaneous_Adjustment__c>();

        this.newlyApprovedTimecards = approvedTimecards;
        this.approvedModifiedTimecards = approvedModifiedTimecards;
        this.newlyUnapprovedTimecards = unapprovedTimecards;
        this.existingMAsByProjectAndDate = new Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>>();
        this.rolledUpMAsByProjectAndDate = new Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>>();
        this.billedMAsByProject = new Map<Id, Map<Id, pse__Miscellaneous_Adjustment__c>>();
        this.triggerTimecardIds = new Set<Id>();

        Set<Id> assignmentIds = new Set<Id>();
        for (pse__Timecard__c approvedTimecard : this.newlyApprovedTimecards) {
            this.triggerTimecardIds.add(approvedTimecard.Id);
            if (approvedTimecard.pse__Assignment__c != null) {
                assignmentIds.add(approvedTimecard.pse__Assignment__c);
            }
        }

        Set<Id> maIds = new Set<Id>();
        for (pse__Timecard__c unapprovedTimecard : this.newlyUnapprovedTimecards) {
            this.triggerTimecardIds.add(unapprovedTimecard.Id);
            if (unapprovedTimecard.pse__Assignment__c != null) {
                assignmentIds.add(unapprovedTimecard.pse__Assignment__c);
            }

            if (unapprovedTimecard.Miscellaneous_Adjustment__c != null) {
                maIds.add(unapprovedTimecard.Miscellaneous_Adjustment__c);
                unapprovedTimecard.Miscellaneous_Adjustment__c = null;
            }
        }

        for (pse__Timecard__c modifiedTimecard : this.approvedModifiedTimecards) {
            this.triggerTimecardIds.add(modifiedTimecard.Id);
            if (modifiedTimecard.pse__Assignment__c != null) {
                assignmentIds.add(modifiedTimecard.pse__Assignment__c);
            }

            if (modifiedTimecard.Miscellaneous_Adjustment__c != null) {
                maIds.add(modifiedTimecard.Miscellaneous_Adjustment__c);
            }
        }

        this.existingTimecards = [
            select
                pse__Project__c,
                pse__Start_Date__c,
                pse__End_Date__c,
                pse__Total_Hours__c,
                pse__Approved__c,
                pse__Assignment__c,
                pse__Assignment__r.pse__Bill_Rate__c,
                Miscellaneous_Adjustment__c
            from pse__Timecard__c
            where 
                pse__Project__c in :projectIds and
                pse__Approved__c = true and
                pse__Assignment__r.pse__Bill_Rate__c > 0.0 and
                Id not in :this.newlyUnapprovedTimecards and
                Id not in :this.approvedModifiedTimecards
        ];

        for (pse__Timecard__c timecard : this.existingTimecards) {
            if (timecard.pse__Assignment__c != null) {
                assignmentIds.add(timecard.pse__Assignment__c);
            }

            if (timecard.Miscellaneous_Adjustment__c != null) {
                maIds.add(timecard.Miscellaneous_Adjustment__c);
            }
        }

        this.assignments = new Map<Id, pse__Assignment__c>([
            select 
                Id, 
                pse__Bill_Rate__c,
                pse__Project__c,
                pse__Project__r.Admin_Fee__c
            from pse__Assignment__c
            where 
                Id in :assignmentIds and
                pse__Bill_Rate__c > 0.0
        ]);

        List<pse__Miscellaneous_Adjustment__c> miscAdjustments = [
            select
                Id,
                pse__Amount__c,
                pse__Billing_Event__c,
                pse__Billed__c,
                pse__Project__c,
                pse__Effective_Date__c
            from pse__Miscellaneous_Adjustment__c
            where Id in :maIds
        ];

        System.debug('&&&&& queried ' + miscAdjustments.size() + ' misc adjustments');

        separateMAsIntoBilledAndNonBilled(miscAdjustments); 
    }

    /*
     * After construction of the helper, the trigger calls this method to rollup time to the appropriate miscellaneous adjustments.
     */    
    public void rollupTime() {
        System.debug('&&&&& rollupTime');

        rollupTimeFor(this.newlyApprovedTimecards);
        rollupTimeFor(this.approvedModifiedTimecards);
        rollupTimeFor(this.newlyUnapprovedTimecards);
        rollupTimeFor(this.existingTimecards);

        for (Id projectId : this.rolledUpMAsByProjectAndDate.keySet()) {
            Map<Date, pse__Miscellaneous_Adjustment__c> masByDate = this.rolledUpMAsByProjectAndDate.get(projectId);
            for (pse__Miscellaneous_Adjustment__c ma : masByDate.values()) {
                if (ma.Id == null) {
                    this.newMAs.add(ma);

                    System.debug('&&&&& adding new MA: amount = ' + ma.pse__Amount__c);
                }
                else if (ma.pse__Amount__c > 0.0) {
                    this.modifiedMAs.add(ma);

                    System.debug('&&&&& adding modified MA: amount = ' + ma.pse__Amount__c);
                }
                else {
                    RollupTimeToAdminFeeHelper.orphanedMAs.add(ma);

                    System.debug('&&&&& adding orphaned MA: amount = ' + ma.pse__Amount__c);
                }
            }
        }

        if (!this.newMas.isEmpty()) insert this.newMAs;

        if (!this.modifiedMAs.isEmpty()) update this.modifiedMAs;

        for (pse__Timecard__c timecard : this.newlyApprovedTimecards) {
            pse__Miscellaneous_Adjustment__c miscAdj = findMAFor(timecard, this.rolledUpMAsByProjectAndDate, false);
            if (miscAdj != null) {
                timecard.Miscellaneous_Adjustment__c = miscAdj.Id;
            }
        }
        
        // The following code is to resolve an issue in which a timecard was approved on a project whose billing type was mistakenly set to'
        // a type other than Time and Materials. The project billing type was then changed to Time & Materials and a new timecard
        // was approved on the project. The rollup of time onto the new Admin Fee MA was correct, but the initial approved timecard
        // was not included in the MA related list.
        List<pse__Timecard__c> timecardsToUpdate = new List<pse__Timecard__c>();
        for (pse__Timecard__c timecard : this.existingTimecards) {
            if (timecard.Miscellaneous_Adjustment__c == null && !this.triggerTimecardIds.contains(timecard.Id)) {
                pse__Miscellaneous_Adjustment__c miscAdj = findMAFor(timecard, this.rolledUpMAsByProjectAndDate, false);
                if (miscAdj != null) {
                    timecard.Miscellaneous_Adjustment__c = miscAdj.Id;
                    timecardsToUpdate.add(timecard);
                }
            }
        }
        if (!timecardsToUpdate.isEmpty()) update timecardsToUpdate;
        // End bug fix.
    }

    /*
     * Roll-up time for a specific list of timecards.
     */    
    private void rollupTimeFor(List<pse__Timecard__c> timecards) {
        System.debug('&&&&& rollupTimeFor');
        for (pse__Timecard__c timecard : timecards) {
            if (!isRolledUpOnBilledMA(timecard)) {
                Decimal maAmount = getMAAmount(timecard);
                pse__Miscellaneous_Adjustment__c ma = findMAFor(timecard, this.existingMAsByProjectAndDate, true);
                if (ma == null) {
                    if (maAmount > 0.0) {
                        ma = findMAFor(timecard, this.rolledUpMAsByProjectAndDate, false);
                        if (ma == null) {
                            System.debug('&&&&& creating new MA');
                            ma = newMA(timecard, maAmount);
                        }
                        else {
                            System.debug('&&&&& found MA in rolled up MAs');
                            ma.pse__Amount__c += maAmount;
                        }
                    }
                }
                else {
                    System.debug('&&&&& found MA in existing MAs');
                    ma.pse__Amount__c = maAmount;
                }

                if (ma != null) {
                    System.debug('&&&&& adding ma to map: project is ' + ma.pse__Project__c + ', effective date is ' + String.valueOf(ma.pse__Effective_Date__c));
                    addToMap(ma, this.rolledUpMAsByProjectAndDate);
                }
            }
        }
    }

    /*
     * Return true if this timecard is associated with a billed miscellaneous adjustment
     */    
    private boolean isRolledUpOnBilledMA(pse__Timecard__c timecard) {
        boolean isBilled = false;
        if (timecard.Miscellaneous_Adjustment__c != null) {
            if (this.billedMAsByProject.containsKey(timecard.pse__Project__c)) {
                Map<Id, pse__Miscellaneous_Adjustment__c> maMap = this.billedMAsByProject.get(timecard.pse__Project__c);
                if (maMap.containsKey(timecard.Miscellaneous_Adjustment__c)) {
                    isBilled = true;
                }
            }
        }
        return isBilled;
    }

    /*
     * Find the miscellaneous adjustment from the specified map whose project corresponds
     * to the timecard project and whose effective date is the end of the month in which the timecard ends.
     */    
    private pse__Miscellaneous_Adjustment__c findMAFor(pse__Timecard__c timecard, 
                                                       Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>> masByProjectAndDate,
                                                       boolean remove) {
        Date effectiveDate = timecard.pse__End_Date__c.addMonths(1).toStartOfMonth().addDays(-1);
        System.debug('&&&&& findMAFor: remove = ' + remove + '; effective date is ' + String.valueOf(effectiveDate));

        pse__Miscellaneous_Adjustment__c miscAdjustment = null;
        if (masByProjectAndDate.containsKey(timecard.pse__Project__c)) {
            Map<Date, pse__Miscellaneous_Adjustment__c> masByDate = masByProjectAndDate.get(timecard.pse__Project__c);

            System.debug('&&&&& finding ma by date: ' + String.valueOf(effectiveDate) + ', masByDate is ' + (masByDate == null ? 'null' : 'not null'));

            if (masByDate != null && masByDate.containsKey(effectiveDate)) {
                System.debug('&&&&& found ma');
                if (remove) {
                    miscAdjustment = masByDate.remove(effectiveDate);
                }
                else {
                    miscAdjustment = masByDate.get(effectiveDate);
                }
            }
        }

        return miscAdjustment;         
    }

    /*
     * Get the miscellaneous adjustment amount as a function of the timecard total hours and the 
     * assignment bill rate.
     */    
    public Decimal getMAAmount(pse__Timecard__c timecard) {
        System.debug('&&&&& getMAAmount');
        Decimal maAmount = 0.0;
        if (timecard.pse__Assignment__c != null && this.assignments.containsKey(timecard.pse__Assignment__c)) {
            pse__Assignment__c assignment = this.assignments.get(timecard.pse__Assignment__c);
            Decimal billRate = assignment.pse__Bill_Rate__c;

            Decimal adminFeePercentage = 0.0;
            if (assignment.pse__Project__c != null && assignment.pse__Project__r.Admin_Fee__c != null && assignment.pse__Project__r.Admin_Fee__c > 0.0) {
                adminFeePercentage = assignment.pse__Project__r.Admin_Fee__c / 100.0;
            }

            System.debug('&&&&& billRate = ' + billRate + ', adminFeePercentage = ' + adminFeePercentage);

            if (billRate != null && billRate > 0.0 && adminFeePercentage > 0.0 && timecard.pse__Approved__c) {
                maAmount = timecard.pse__Total_Hours__c * billRate * adminFeePercentage;
                
                System.debug('&&&&& maAmount: ' + maAmount);
            }
        }
        return maAmount;
    }

    /*
     * Separate the miscellaneous adjustments into two groups, those that have been billed and those that have not.
     */    
    private void separateMAsIntoBilledAndNonBilled(List<pse__Miscellaneous_Adjustment__c> miscAdjustments) {
        System.debug('&&&&& separateMAsIntoBilledAndNonBilled');
        for (pse__Miscellaneous_Adjustment__c miscAdjustment : miscAdjustments) {
            if (miscAdjustment.pse__Billed__c) {
                System.debug('&&&&& adding MA to billed MAs');
                if (this.billedMAsByProject.containsKey(miscAdjustment.pse__Project__c)) {
                    this.billedMAsByProject.get(miscAdjustment.pse__Project__c).put(miscAdjustment.Id, miscAdjustment);
                }
                else {
                    Map<Id, pse__Miscellaneous_Adjustment__c> maMap = new Map<Id, pse__Miscellaneous_Adjustment__c>();
                    maMap.put(miscAdjustment.Id, miscAdjustment);
                    this.billedMAsByProject.put(miscAdjustment.pse__Project__c, maMap);
                }
            }
            else {
                System.debug('&&&&& adding MA to existing MAs');
                addToMap(miscAdjustment, this.existingMAsByProjectAndDate);
            }
        }
    }

    /*
     * Add a specific miscellaneous adjustment to the map of miscellaneous adjustments by project and effective date.
     */    
    private void addToMap(pse__Miscellaneous_Adjustment__c ma, Map<Id, Map<Date, pse__Miscellaneous_Adjustment__c>> masByProjectAndDate) {
        if (masByProjectAndDate.containsKey(ma.pse__Project__c)) {
            masByProjectAndDate.get(ma.pse__Project__c).put(ma.pse__Effective_Date__c, ma);
        }
        else {
            Map<Date, pse__Miscellaneous_Adjustment__c> maMap = new Map<Date, pse__Miscellaneous_Adjustment__c>();
            maMap.put(ma.pse__Effective_Date__c, ma);
            masByProjectAndDate.put(ma.pse__Project__c, maMap);
        }
    }

    /*
     * Create a new miscellaneous adjustment from a timecard.
     */    
    private pse__Miscellaneous_Adjustment__c newMA(pse__Timecard__c timecard, Decimal amount) {
        Date effectiveDate = timecard.pse__End_Date__c.addMonths(1).toStartOfMonth().addDays(-1);
        String maName = getMAName(timecard, effectiveDate);
        pse__Miscellaneous_Adjustment__c miscAdj = new pse__Miscellaneous_Adjustment__c(
            Name = maName,
            pse__Effective_Date__c = effectiveDate,
            pse__Amount__c = amount,
            pse__Transaction_Category__c = 'Ready-to-Bill Revenue',
            pse__Status__c = 'Approved',
            pse__Approved__c = true,
            pse__Include_In_Financials__c = true,
            pse__Project__c = timecard.pse__Project__c
        );
        return miscAdj;
    }

    /*
     * Get the miscellaneous adjustment name. If there are other billed miscellaneous adjustments with the
     * same effective date, then add a numeral to indicate a sequence number.
     */    
    private String getMAName(pse__Timecard__c timecard, Date maEffectiveDate) {
        Integer numberOfMAs = 0;
        if (this.billedMAsByProject.containsKey(timecard.pse__Project__c)) {
            Map<Id, pse__Miscellaneous_Adjustment__c> maList = this.billedMAsByProject.get(timecard.pse__Project__c);
            for (pse__Miscellaneous_Adjustment__c ma : maList.values()) {
                if (ma.pse__Effective_Date__c.isSameDay(maEffectiveDate)) {
                    numberOfMAs += 1;
                }
            }
        }

        String maNamePrefix =  'Admin Fee';
        if (numberOfMAs > 0) {
            maNamePrefix = maNamePrefix + ' ' + String.valueOf(numberOfMAs + 1);
        }
        return maNamePrefix + ' - ' + months.get(maEffectiveDate.month()) + ' ' + maEffectiveDate.year();
    }
}