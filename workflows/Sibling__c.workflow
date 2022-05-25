<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Sibling_Program_MTM_Name</fullName>
        <description>Created for CR-20210409-15073</description>
        <field>Name</field>
        <formula>Governing_Program__r.Program_Acronym__c  + &quot;-&quot; +   Recipient_Program__r.Name</formula>
        <name>Update Sibling Program MTM Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Sibling Program MTM Name</fullName>
        <actions>
            <name>Update_Sibling_Program_MTM_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20210409-15073</description>
        <formula>ISNEW() ||  ( ISCHANGED(Governing_Program__c) || ISCHANGED( Recipient_Program__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
