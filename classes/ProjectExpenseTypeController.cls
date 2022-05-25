/*
    Purpose:
       This controller provides the capability to manage the bill-ability of expense types for each project.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/7/2015
*/

public with sharing class ProjectExpenseTypeController {

	private final Id projectId;
    private ApexPages.StandardController stdController;

    public String projectName {get; set;}
    public Project_Expense_Type__c[] projectExpenseTypes {get; set;}
    public boolean petsApply {get; set;}

    public ProjectExpenseTypeController(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.projectId = (Id) stdController.getId();
        pse__Proj__c project = [
            select 
                Name,
                Billable_Expense_Types_Apply__c
            from pse__Proj__c
            where Id = :projectId
        ];

        this.projectName = project.Name;
        petsApply = project.Billable_Expense_Types_Apply__c;

        if (petsApply) {
            setProjectExpenseTypes();
        }
        else {
            String msg = 'This project is not designated for expense type management. Please check the Billable Expense Types Apply checkbox.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));
        }
    }

    public PageReference save() {
        System.debug('&&&&& save projectExpenseTypes: ' + this.projectExpenseTypes.size());
        List<Project_Expense_Type__c> newPETs = new List<Project_Expense_Type__c>();
        List<Project_Expense_Type__c> modifiedPETs = new List<Project_Expense_Type__c>();
        for (Project_Expense_Type__c projectExpenseType : this.projectExpenseTypes) {
            if (projectExpenseType.Id != null) {
                modifiedPETs.add(projectExpenseType);
            }
            else {
                newPETs.add(projectExpenseType);
            }
        }

        if (!modifiedPETs.isEmpty()) {
            update modifiedPETs;
        }

        if (!newPETs.isEmpty()) {
            insert newPETs;
        }

        return stdController.cancel();
    }

    public PageReference cancel() {
        return stdController.cancel();
    }

    private void setProjectExpenseTypes() {
        List<String> expenseTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = pse__Expense__c.pse__Type__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListEntry : pickListEntries) {
            expenseTypes.add(pickListEntry.getValue());
        }
        expenseTypes.sort();

        List<Project_Expense_Type__c> petList = [
            select
                Id,
                Name,
                Billable__c
            from Project_Expense_Type__c
            where Project__c = :projectId
            order by Name
        ];

        Map<String, Project_Expense_Type__c> petMap = new Map<String, Project_Expense_Type__c>();
        for (Project_Expense_Type__c pet : petList) {
            petMap.put(pet.Name, pet);
        }

        this.projectExpenseTypes = new List<Project_Expense_Type__c>();
        for (String expenseType : expenseTypes) {
            if (petMap.containsKey(expenseType)) {
                this.projectExpenseTypes.add(petMap.get(expenseType));
            }
            else {
                this.projectExpenseTypes.add(
                    new Project_Expense_Type__c(
                        Name = expenseType,
                        Billable__c = false,
                        Project__c = projectId
                    )
                );
            }
        }
        System.debug('&&&&& projectExpenseTypes: ' + this.projectExpenseTypes.size());
    }
}