<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Set_Job_Component_Name</fullName>
        <field>Name</field>
        <formula>IF(
NOT(ISBLANK(TEXT(Window_Size__c))),
LEFT(TEXT(Component__c) + &apos;: &apos; + TEXT(Size__c) + &apos;,Window&apos; + TEXT(Window_Size__c), 80),
IF(NOT(ISBLANK(SKU__c)), LEFT(SKU__c + &apos; - &apos; + TEXT(Component__c) + &apos;: &apos; + TEXT(Size__c), 80), LEFT(TEXT(Component__c) + &apos;: &apos; + TEXT(Size__c), 80)
))</formula>
        <name>FU_Set_Job_Component_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Set Job Ticket Component Name</fullName>
        <actions>
            <name>FU_Set_Job_Component_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
