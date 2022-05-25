<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Name</fullName>
        <field>Name</field>
        <formula>Perk_Template__r.Name + &quot;-&quot; + Status__c + &quot;-&quot; + TEXT(MONTH(Perk_Available_Date__c)) + &quot;/&quot; + TEXT(DAY(Perk_Available_Date__c)) + &quot;/&quot; + TRIM(RIGHT(TEXT(YEAR(Perk_Available_Date__c)), 2))</formula>
        <name>zzzUpdate Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>zzzSet Reference Perk Name</fullName>
        <actions>
            <name>Update_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Reference_Perk__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Perk Template</value>
        </criteriaItems>
        <description>Sets the Reference Perk Name when the Record Type != &quot;Perk Template&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
