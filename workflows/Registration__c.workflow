<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Registration_Escalated_Travel_Comp_Request</fullName>
        <description>Registration Escalated Travel Comp Request</description>
        <protected>false</protected>
        <recipients>
            <field>Requester_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Registration_Travel_Compensation_Request_Sent_to_escalation_group</template>
    </alerts>
    <alerts>
        <fullName>Registration_Reminder_Travel_Comp_Requests_That_Require_Approval</fullName>
        <description>Registration_Reminder_Travel_Comp_Requests_That_Require_Approval</description>
        <protected>false</protected>
        <recipients>
            <field>Department_Authorization__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Registration_Reminder_You_Have_Pending_Travel_Compensation_Requests</template>
    </alerts>
    <alerts>
        <fullName>Registration_Travel_Comp_Requires_Approval_Email_Alert_Escalated_Group</fullName>
        <description>Registration Travel Comp Requires Approval Email Alert - Escalated Group</description>
        <protected>false</protected>
        <recipients>
            <field>Department_Authorization__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Registration_Travel_Comp_Requires_Approval_Email_Template_Escalated_Group</template>
    </alerts>
    <alerts>
        <fullName>Registration_Travel_Compensation_Request_Approved</fullName>
        <description>Registration Travel Compensation Request - Approved</description>
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
        <template>unfiled$public/Registration_Travel_Compensation_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Registration_Travel_Compensation_Request_Rejected</fullName>
        <description>Registration Travel Compensation Request - Rejected</description>
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
        <template>unfiled$public/Registration_Travel_Compensation_Request_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_TR_Approved_Date_field_Update_to_Blnk</fullName>
        <description>Created for CR-20210511-15133.</description>
        <field>Travel_Request_Approved_Date__c</field>
        <name>FU_TR_Approved Date field Update to Blnk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_TravelRequestApprovedDate</fullName>
        <description>Created for CR-20210511-15133.</description>
        <field>Travel_Request_Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>FU_TravelRequestApprovedDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Regis_Comp_Approval_Status_Approved</fullName>
        <description>Created for CR-20210511-15133.</description>
        <field>Travel_Compensation_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Regis_Comp__Approval_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Regis_Comp_Approval_Status_Rejected</fullName>
        <description>Created for CR-20210511-15133.</description>
        <field>Travel_Compensation_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Regis_Comp_Approval_Status_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Registration_Com_Approval_Status_Pending</fullName>
        <description>Created for CR-20210511-15133.</description>
        <field>Travel_Compensation_Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Registration_Com_Approval_Status_Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Registration_Set_Cancelled_Date</fullName>
        <description>Set Registration Cancelled Date</description>
        <field>Date_Cancelled__c</field>
        <formula>NOW()</formula>
        <name>Registration Set Cancelled Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Un_check</fullName>
        <description>Created for CR-20201106-14676</description>
        <field>Automated_Update__c</field>
        <literalValue>0</literalValue>
        <name>FU_Uncheck_Automated_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Registration Cancelled</fullName>
        <actions>
            <name>Registration_Set_Cancelled_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>Run when Registration Status is Cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Registration_Reminder_Travel_Comp_Requests_That_Require_Approval</fullName>
        <actions>
            <name>Registration_Reminder_Travel_Comp_Requests_That_Require_Approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20210511-15133.</description>
        <formula>AND(      Travel_Assistance_Request__c,     ISPICKVAL( Travel_Compensation_Approval_Status__c , &apos;Pending&apos; ),     NOT( ISNULL(Department_Authorization__c ) ),     Start_Date__c - 8 = TODAY()        )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update_Registration_Automated_Update</fullName>
        <actions>
            <name>Un_check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Registration__c.Automated_Update__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created for CR-20201106-14676.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
