<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>JTE_Set_Total_Price_FU</fullName>
        <field>Total_Price__c</field>
        <formula>IF (NOT(ISBLANK(Mail_Quantity__c)) || NOT(ISBLANK( Component_Price__c )), 
Mail_Quantity__c * Component_Price__c, 
0)</formula>
        <name>JTE: Set Total Price FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>JTE%3A Set Total Price</fullName>
        <actions>
            <name>JTE_Set_Total_Price_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Mail_Quantity__c) || ISCHANGED(Component_Price__c) ||  ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
