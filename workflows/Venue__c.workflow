<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autoname_Event_Venue_FU</fullName>
        <field>Name</field>
        <formula>Venue__r.Account_Formal_Name__c</formula>
        <name>Autoname – Event Venue FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Autoname %E2%80%93 Event Venue</fullName>
        <actions>
            <name>Autoname_Event_Venue_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Automatically update the Name value of an Event Venue based on a combination of values</description>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
