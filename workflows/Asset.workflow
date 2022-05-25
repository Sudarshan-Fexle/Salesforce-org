<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Tech_Name_field</fullName>
        <description>Deprecated w.r.t CR-20211118-15596</description>
        <field>Name</field>
        <formula>Competitor1__r.Name</formula>
        <name>zzzUpdate Tech Name field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Tech Name field</fullName>
        <actions>
            <name>Update_Tech_Name_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Deprecated w.r.t CR-20211118-15596</description>
        <formula>ISCHANGED(Competitor1__c) || NOT(ISBLANK(Competitor1__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
