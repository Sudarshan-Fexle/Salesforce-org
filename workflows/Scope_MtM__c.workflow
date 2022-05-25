<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Populate_Scope_MtM_Name</fullName>
        <description>Will auto populate Scope MtM name field with Scope Name.</description>
        <field>Name</field>
        <formula>Scope__r.Name</formula>
        <name>FU_Populate_Scope_MtM_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Populate_Scope_MtM_Name</fullName>
        <actions>
            <name>FU_Populate_Scope_MtM_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Scope_MtM__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Will auto populate Scope MtM name field with Scope Name.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
