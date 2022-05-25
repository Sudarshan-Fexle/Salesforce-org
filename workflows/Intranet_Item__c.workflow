<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Change_Configuration_Item_to_False</fullName>
        <description>Set Change Configuration Item to False</description>
        <field>Change_Configuration_Item__c</field>
        <literalValue>0</literalValue>
        <name>Set Change Configuration Item to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Change Configuration Item Field</fullName>
        <actions>
            <name>Set_Change_Configuration_Item_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Intranet_Item__c.Change_Configuration_Item__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Field must be checked to modify an item marked as a Configuration item.  This workflow runs to reset the field to un-checked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
