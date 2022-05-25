<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ATx_Transfer_Failed_Notification</fullName>
        <ccEmails>bneal@eab.com,xmpiesupport@eab.com,kbrenneman@eab.com</ccEmails>
        <description>ATx: Transfer Failed Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Art_Prep_Team</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/Artifact_Transfer_Transfer_Failed</template>
    </alerts>
    <alerts>
        <fullName>ATx_Transfer_Failed_Notification_Application_Support</fullName>
        <ccEmails>applicationsupport@eab.com;bneal@eab.com;kbrenneman@eab.com;xmpiesupport@eab.com</ccEmails>
        <description>ATx: Transfer Failed Notification - Application Support</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/Artifact_Transfer_Transfer_Failed</template>
    </alerts>
    <alerts>
        <fullName>ATx_Transfer_Failed_Notification_Data_Managers</fullName>
        <ccEmails>kbrenneman@eab.com;bneal@eab.com;xmpiesupport@eab.com</ccEmails>
        <description>ATx: Transfer Failed Notification - Data Managers</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/Artifact_Transfer_Transfer_Failed</template>
    </alerts>
    <alerts>
        <fullName>ATx_Transfer_Failed_Notification_Mail_Services</fullName>
        <ccEmails>EnrollmentServicesMailServices@eab.com;kbrenneman@eab.com;bneal@eab.com; xmpiesupport@eab.com</ccEmails>
        <description>ATx: Transfer Failed Notification - Mail Services</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/Artifact_Transfer_Transfer_Failed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Artifact_Transfer_Name</fullName>
        <description>Updates Artifact Transfer Name</description>
        <field>Name</field>
        <formula>TEXT(Artifact__r.Type__c) &amp; &quot; : &quot; &amp; TEXT(Artifact_Target__c)</formula>
        <name>Artifact Transfer: Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ATx%3A Transfer Failed</fullName>
        <actions>
            <name>ATx_Transfer_Failed_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify Project Manager when artifact transfer fails</description>
        <formula>AND(     ISCHANGED(Status__c),     ISPICKVAL(Status__c, &quot;Failure&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF Rule%3A Artifact Transfer Name</fullName>
        <actions>
            <name>Artifact_Transfer_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Artifact Transfer Name</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
