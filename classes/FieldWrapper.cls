/*
Purpose         :   Field Wrapper Class

Created By      :   Abhinav Sharma

Created Date    :   12/15/2019

Current Version :   v1.0

Revision Log    :   V_1.0 Created
                    V_1.1 Modified By -Abhinav Sharma - 6/5/2020 - CR-20200601-14125 - apply "Without sharing" here in the class definition
*/
public without sharing class FieldWrapper 
{
    @AuraEnabled public String fieldName {get;set;}
    @AuraEnabled public String fieldLabel {get;set;}
}