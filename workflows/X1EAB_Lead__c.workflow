<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Update_1EABLead_Name</fullName>
        <description>Created via CR-20200804-14401</description>
        <field>Name</field>
        <formula>TEXT(Date_Passed_to_Sales__c)+&quot; - &quot;+ LEFT(Institution__c,50) + &quot; - &quot; +  Primary_Program__r.Program_Acronym__c</formula>
        <name>zzzFU Update 1EABLead Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>zzzWF_Update_1EABLead_Name</fullName>
        <actions>
            <name>FU_Update_1EABLead_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Created via CR-20200804-14401</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
