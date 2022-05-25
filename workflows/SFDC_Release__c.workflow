<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Populate_Actual_Release_Date</fullName>
        <description>CR-20170327-10779</description>
        <field>Actual_Release_Date__c</field>
        <formula>TODAY()</formula>
        <name>FU_Populate_Actual_Release_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Populate_Actual_Release_Date_On_Release</fullName>
        <actions>
            <name>FU_Populate_Actual_Release_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Release__c.Status__c</field>
            <operation>equals</operation>
            <value>Deployed</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFDC_Release__c.Actual_Release_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Created for CR-20170327-10779</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
