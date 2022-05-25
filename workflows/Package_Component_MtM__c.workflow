<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Update_Package_Component_Name</fullName>
        <description>Created via CR-20210323-15016</description>
        <field>Name</field>
        <formula>TEXT(Job_Ticket_MtM__r.Component_Type__c)+ &apos;-&apos; + Job_Ticket_MtM__r.Component_Counter_Id__c</formula>
        <name>FU Update Package Component Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF Update JobTicket On Package Comp MTM</fullName>
        <active>false</active>
        <formula>AND(NOT(ISNULL(Mail_Package__c)),ISCHANGED(Mail_Package__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_AutoPopulate_Package_Component_MtM_Name</fullName>
        <actions>
            <name>FU_Update_Package_Component_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Job_Ticket_MtM__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
