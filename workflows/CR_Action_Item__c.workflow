<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CR_Action_Item_Update_Completed_DateTim</fullName>
        <field>Completed_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>CR Action Item: Update Completed DateTim</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CR Action Item Status update to Completed Date Time</fullName>
        <actions>
            <name>CR_Action_Item_Update_Completed_DateTim</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CR_Action_Item__c.Action_Item_Status__c</field>
            <operation>equals</operation>
            <value>Completed,Resolved</value>
        </criteriaItems>
        <description>Runs when the Release, Change Request, Objective, or Record Type field is updated on the record</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CR Action Item Status update to Completed DateTime</fullName>
        <actions>
            <name>CR_Action_Item_Update_Completed_DateTim</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CR_Action_Item__c.Action_Item_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
