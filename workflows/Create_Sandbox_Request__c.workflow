<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sandbox_Refresh_Recipient</fullName>
        <description>Sandbox Refresh Recipient</description>
        <protected>false</protected>
        <recipients>
            <recipient>User_For_Sandbox_Creation</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sandbox_Refresh_Detail_Record_Notification</template>
    </alerts>
    <rules>
        <fullName>WR_Sanbox_Refresh_Detail</fullName>
        <actions>
            <name>Sandbox_Refresh_Recipient</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Create_Sandbox_Request__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
