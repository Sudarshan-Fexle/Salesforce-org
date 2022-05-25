<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Update_Mail_Package_Name</fullName>
        <field>Name</field>
        <formula>Mail_Package_Counter_Id__c</formula>
        <name>FU Update Mail Package Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF Update Mail Package Name</fullName>
        <actions>
            <name>FU_Update_Mail_Package_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Mail_Package_Counter_Id__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
