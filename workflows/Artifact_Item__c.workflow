<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Artifact_Item_Name</fullName>
        <field>Name</field>
        <formula>File_Name__c</formula>
        <name>Artifact Item: Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF Rule%3A Artifact Item Name</fullName>
        <actions>
            <name>Artifact_Item_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Artifact Item Name</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
