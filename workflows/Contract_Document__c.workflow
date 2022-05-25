<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Profile_Reviewed_by_Legal_date</fullName>
        <field>Profile_Reviewed_by_Legal_Date__c</field>
        <formula>Today()</formula>
        <name>Profile Reviewed by Legal date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Profile Reviewed by Legal date</fullName>
        <actions>
            <name>Profile_Reviewed_by_Legal_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract_Document__c.Legal_Review_Status__c</field>
            <operation>equals</operation>
            <value>Profile Reviewed by Legal</value>
        </criteriaItems>
        <description>Update with Today() to this field when Legal review status is profile reviewed by legal</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
