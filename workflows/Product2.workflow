<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_On_New_Product</fullName>
        <description>Notification_On_New_Product</description>
        <protected>false</protected>
        <recipients>
            <recipient>lbeale@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notification_On_New_Product</template>
    </alerts>
    <rules>
        <fullName>Notification_On_New_Product</fullName>
        <actions>
            <name>Notification_On_New_Product</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20181113-12743.</description>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
