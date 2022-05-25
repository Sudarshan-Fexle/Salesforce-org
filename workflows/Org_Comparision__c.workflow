<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateFormalName</fullName>
        <description>This is used to update Formal Name</description>
        <field>Formal_Name__c</field>
        <formula>Name +&quot;-&quot;+ TEXT(Type__c) +&quot;-&quot;+ Release__r.Name +&quot;-&quot;+ TEXT( Last_Modified_Date_Bar__c)</formula>
        <name>UpdateFormalName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>updateFormalName</fullName>
        <actions>
            <name>UpdateFormalName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This is used to populate Formal Name</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
