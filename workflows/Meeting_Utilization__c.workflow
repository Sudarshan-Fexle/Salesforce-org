<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Escalated_Travel_Comp_Request</fullName>
        <description>zzzEscalated Travel Comp Request</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Travel_Compensation_Request_Sent_to_escalation_group</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Travel_Comp_Requests_That_Require_Approval</fullName>
        <description>zzzReminder_Travel_Comp_Requests_That_Require_Approval</description>
        <protected>false</protected>
        <recipients>
            <field>Department_Authorization__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Reminder_You_Have_Pending_Travel_Compensation_Requests</template>
    </alerts>
    <alerts>
        <fullName>Travel_Comp_Requires_Approval_Email_Alert_Escalated_Group</fullName>
        <description>zzzTravel Comp Requires Approval Email Alert - Escalated Group</description>
        <protected>false</protected>
        <recipients>
            <field>Department_Authorization__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Travel_Comp_Requires_Approval_Email_Template_Escalated_Group</template>
    </alerts>
    <alerts>
        <fullName>Travel_Compensation_Request_Approved</fullName>
        <description>zzzTravel Compensation Request - Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Department_Authorization__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Requester_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Travel_Compensation_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Travel_Compensation_Request_Rejected</fullName>
        <description>zzzTravel Compensation Request - Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Department_Authorization__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Requester_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>sfadmin@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Travel_Compensation_Request_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_Populate_IsEsclated_On_MeetingUtiliza</fullName>
        <description>Created for CR-20170509-10928
Travel Compensation Field References Removed for CR-20210511-15133</description>
        <field>Is_Esclated__c</field>
        <literalValue>1</literalValue>
        <name>zzzFUPopulateIsEsclatedOn_MeetingUtiliza</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MeetingUtiliz_Approval_Status_Approved</fullName>
        <description>Created for CR-20170509-10928.
Travel Compensation Field References Removed for CR-20210511-15133</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>zzzMeetingUtilizApproval_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MeetingUtiliz_Approval_Status_Pending</fullName>
        <description>Created for CR-20170509-10928.
Travel Compensation Field References Removed for CR-20210511-15133</description>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>zzzMeetingUtiliz_Approval_Status_Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MeetingUtiliz_Approval_Status_Rejected</fullName>
        <description>Created for CR-20170509-10928.
Travel Compensation Field References Removed for CR-20210511-15133.</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>zzzMeetingUtilizApproval_Status_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Reminder_Travel_Comp_Requests_That_Require_Approval</fullName>
        <actions>
            <name>Reminder_Travel_Comp_Requests_That_Require_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Created for CR-20170509-10928.</description>
        <formula>AND(      Travel_Assistance_Request__c,     ISPICKVAL(Approval_Status__c , &apos;Pending&apos; ),     NOT( ISNULL(Department_Authorization__c ) ),     Start_Date__c - 8 = TODAY()        )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Populate_IsEsclated_On_MeetingUtilization</fullName>
        <actions>
            <name>FU_Populate_IsEsclated_On_MeetingUtiliza</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Created for CR-20170509-10928.</description>
        <formula>AND(       NOT(ISNEW()),       Is_Esclated__c = false,     ISPICKVAL(Approval_Status__c , &apos;Pending&apos;),     (Start_Date__c) - 7 &lt;= TODAY(),     NOT(ISBLANK(Department_Authorization__c)),      Travel_Assistance_Request__c = true  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
