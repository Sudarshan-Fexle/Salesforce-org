<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Reference_Request_Contact_Approved_Notification</fullName>
        <description>Reference Request Contact Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Request_Contact_Approved</template>
    </alerts>
    <alerts>
        <fullName>Reference_Request_Contact_Denied_Notification</fullName>
        <description>Reference Request Contact Denied Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Marketer__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Request_Contact_Approved</template>
    </alerts>
    <alerts>
        <fullName>Reference_Request_Contact_Released_Notification</fullName>
        <description>Reference Request Contact Released Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Marketer__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Request_Contact_Released</template>
    </alerts>
    <fieldUpdates>
        <fullName>Release_Date_Update</fullName>
        <field>Date_Reference_Released__c</field>
        <formula>TODAY()</formula>
        <name>Release Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Denied</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Status Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Reference Request Contact Released</fullName>
        <actions>
            <name>Release_Date_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference_Request_Contact__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Released</value>
        </criteriaItems>
        <description>Update the Release Date when the status is Released.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Submit_for_Approval</fullName>
        <assignedToType>owner</assignedToType>
        <description>[task automatically generated when approval request was submitted]</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Submit for Approval</subject>
    </tasks>
</Workflow>
