<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PT_Error_Notification_to_Queue</fullName>
        <description>PT: Error Notification to Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>Print_MIS_Error_Notifications</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/Print_MIS_Error_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Short_Response</fullName>
        <description>Populate short response on Web Service Log</description>
        <field>Short_Response__c</field>
        <formula>LEFT(Response_Message__c, 255)</formula>
        <name>Update Short Response</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WSL%3A Short Response Update</fullName>
        <actions>
            <name>Update_Short_Response</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Web_Service_Log__c.Response_Message__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update short response (Text(255)) from Response Message (long text)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
