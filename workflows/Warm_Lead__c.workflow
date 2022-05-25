<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_C_suite_checkbox</fullName>
        <field>C_Suite__c</field>
        <literalValue>1</literalValue>
        <name>Update C-suite checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Warm_Lead_Status</fullName>
        <field>Status__c</field>
        <literalValue>Opportunity Identified (Moved to Opportunity)</literalValue>
        <name>Update Warm Lead Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_warm_lead_followed_up_date</fullName>
        <description>puts today in followed up date when fired by status leaving pending</description>
        <field>Followed_Up_Date__c</field>
        <formula>Today()</formula>
        <name>update warm lead followed up date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Warm Leads Num of Opps</fullName>
        <actions>
            <name>Update_Warm_Lead_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_warm_lead_followed_up_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Warm_Lead__c.Number_of_Warm_Leads__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Warm_Lead__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>Used to initiate a field update on warm leads Status.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Updates Follow Up When Status Changes</fullName>
        <actions>
            <name>update_warm_lead_followed_up_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Warm_Lead__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>updates warm lead followed-up date when status changes from pending</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Validate C-suite checkbox</fullName>
        <actions>
            <name>Update_C_suite_checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Warm_Lead__c.Contact_level__c</field>
            <operation>equals</operation>
            <value>CXO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Warm_Lead__c.C_Suite__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
