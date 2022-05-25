<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>JTE_Update_Component_Price</fullName>
        <field>Component_Price__c</field>
        <formula>Price_for_Color_Breakdown__c</formula>
        <name>JTE: Update Component Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Job_Ticket_Estimate__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>JTEC%3A Update Component Price on JTE</fullName>
        <actions>
            <name>JTE_Update_Component_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Price_for_Color_Breakdown__c) || ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
