<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sends_an_email_to_notify_Content_manager_that_a_Scheduled_Item_is_ready_for_revi</fullName>
        <ccEmails>boardroomnews@advisory.com</ccEmails>
        <description>Sends an email to notify Content manager that a Scheduled Item is ready for review</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Intranet/Intranet_Schedule_Ready_for_Review</template>
    </alerts>
    <rules>
        <fullName>Schedule Ready for Review</fullName>
        <actions>
            <name>Sends_an_email_to_notify_Content_manager_that_a_Scheduled_Item_is_ready_for_revi</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Runs when an Intranet Schedule is updated to an Approval Status of &apos;Ready for Review&apos;</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Intranet_Schedule__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),			 		ISPICKVAL(Active_Status__c, &apos;Active&apos;),   ISPICKVAL(Approval_Status__c, &apos;Ready for Review&apos;)  	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
