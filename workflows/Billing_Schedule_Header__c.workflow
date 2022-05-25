<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BSH_Populate_Invoicing_Instruct</fullName>
        <field>Invoicing_Instructions__c</field>
        <formula>Invoicing_Instructions__c</formula>
        <name>BSH: Populate Invoicing Instruct</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BSH%3A Populate Special Invoicing Instructions</fullName>
        <actions>
            <name>BSH_Populate_Invoicing_Instruct</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This should only run on creating of the BSH record.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
