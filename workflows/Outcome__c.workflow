<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Outcome_Type</fullName>
        <field>Outcome_Type__c</field>
        <formula>RecordType.Name</formula>
        <name>zzzUpdate Outcome Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>zzzCreate Outcome Record</fullName>
        <actions>
            <name>Update_Outcome_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Runs when an Outcome record is created, or when the record type is changed and the new record type is not ‘Other Outcome’.  If the new record type is ‘Other Outcome’, then the user is required to enter a value.</description>
        <formula>AND(     ISCHANGED(RecordTypeId),     RecordType.DeveloperName !=  $Label.Outcome_RT_Dev_Name )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
