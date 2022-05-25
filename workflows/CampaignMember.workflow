<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Campaign_Member_Update_External_Id_FU</fullName>
        <description>Updates External Id on Campaign Member based on lookup objects</description>
        <field>External_Id__c</field>
        <formula>IF(ISBLANK(ContactId),Lead.Counter_ID__c,Contact.Counter_ID__c) + &quot;_&quot; + CASESAFEID(Campaign.Id)</formula>
        <name>Campaign Member: Update External Id FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Campaign Member%3A Update Helper</fullName>
        <actions>
            <name>Campaign_Member_Update_External_Id_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Updates the External Id field for integration use.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
