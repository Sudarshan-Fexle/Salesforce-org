<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSS_Request_Approved_Alert</fullName>
        <description>PSS_Request_Approved_Alert</description>
        <protected>false</protected>
        <recipients>
            <field>PSS_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>smerequests@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PSS_Request_Approved_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>PSS_Approval_Status_Approved</fullName>
        <description>Created for CR-20170302-10730.</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>PSS_Approval_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSS_Approval_Status_Pending</fullName>
        <description>Created for CR-20170302-10730.</description>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>PSS_Approval_Status_Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSS_Approval_Status_Rejected</fullName>
        <description>Created for CR-20170302-10730.</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>PSS_Approval_Status_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSS_Resource_Requested_Reset</fullName>
        <description>Created for CR-20170302-10730.</description>
        <field>Resource_Requested__c</field>
        <literalValue>0</literalValue>
        <name>PSS_Resource_Requested_Reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Approved_On_PSS_Request</fullName>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Populate_Approved_On_PSS_Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
