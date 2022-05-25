<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ABC_Revenue_Update_Posted_Date</fullName>
        <field>Rev_Rec_Posted_Date__c</field>
        <formula>NOW()</formula>
        <name>ABC Revenue - Update Posted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ABC Revenue - Recognized to Date Changed</fullName>
        <actions>
            <name>ABC_Revenue_Update_Posted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Recognized_to_Date_Contract__c) || ISCHANGED(Recognized_to_Date_GAAP__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
