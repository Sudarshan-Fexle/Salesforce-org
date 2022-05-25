<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autopopulate_Inventory_Name</fullName>
        <field>Name</field>
        <formula>&quot;INV&quot; + &quot;-&quot; + Job_Ticket_MtM__r.Job_Ticket__r.School_Code__c + &quot;-&quot; + TEXT(Job_Ticket_MtM__r.Job_Ticket_Component__r.Component__c) + &quot;-&quot; + Inv_AutoNumber__c</formula>
        <name>Autopopulate Inventory Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Default_For_Inventory_Component_Code</fullName>
        <field>Inventory_Control_Number__c</field>
        <formula>IF(ISPICKVAL(Production_Tracking__r.Job_Ticket__r.Drop_Type__c, &apos;Pre Planned&apos;), 
Production_Tracking__r.Job_Ticket__r.Name + &apos;-&apos; + Production_Tracking__r.Job_Ticket_MtM__r.Component_Code_Formula__c, 
Production_Tracking__r.Job_Ticket__r.Name + &apos;-&apos; + Production_Tracking__r.Job_Ticket_MtM__r.Component_Counter_Id__c
)</formula>
        <name>FU_Default_For_Inventory_Component_Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Populate_Inventory_Component_Code</fullName>
        <actions>
            <name>FU_Default_For_Inventory_Component_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>WF rule to populate Inventory_Control_Number__c field of Inventory Object,</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update Inventory Name</fullName>
        <actions>
            <name>Autopopulate_Inventory_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will auto-populate the Inventory Name.</description>
        <formula>ISNEW() || ( ISCHANGED( Job_Ticket_MtM__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
