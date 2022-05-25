<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>zzzAutoname</fullName>
        <field>Name</field>
        <formula>Third_Party__r.Account_Formal_Name__c &amp; &apos; : &apos; &amp; Institution__r.Account_Formal_Name__c</formula>
        <name>zzzAutoname</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>zzzAutoname</fullName>
        <actions>
            <name>zzzAutoname</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Automatically rename each Account Relationship Name value after each save.</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
