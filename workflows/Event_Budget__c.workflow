<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autoname_Event_Budget</fullName>
        <field>Name</field>
        <formula>TEXT( Type__c ) + &quot;-&quot; + TEXT( Sub_type__c ) + &quot;-&quot; + TEXT( Day__c )</formula>
        <name>Autoname - Event Budget</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Autoname - Event Budget</fullName>
        <actions>
            <name>Autoname_Event_Budget</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
