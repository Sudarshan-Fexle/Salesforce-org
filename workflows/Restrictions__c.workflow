<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Marketing_Program_Leader</fullName>
        <description>Email Marketing Program Leader</description>
        <protected>false</protected>
        <recipients>
            <field>Marketing_Program_Leader_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/Restriction_Summary_for_Marketing_Program_Lead</template>
    </alerts>
    <alerts>
        <fullName>Email_Primary_RI_AM_Contact</fullName>
        <description>Email Primary RI AM Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_RI_AM_contact_EA_or_AE_or_RM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/Restriction_Summary_for_RI_AM_Owner</template>
    </alerts>
    <alerts>
        <fullName>Reminder_that_Restriction_is_Expiring</fullName>
        <description>Reminder that Restriction is Expiring</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Delegate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Restriction_Expiring</template>
    </alerts>
    <alerts>
        <fullName>Reminder_that_restrictions_are_about_to_expire</fullName>
        <description>Reminder that restrictions are about to expire</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Restriction_Expiration_Alert</template>
    </alerts>
    <alerts>
        <fullName>TB_Reminder_that_Restriction_is_Expiring</fullName>
        <description>Reminder that Restriction is Expiring</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Delegate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Restriction_Expiring</template>
    </alerts>
    <fieldUpdates>
        <fullName>Run_Trigger_to_TRUE</fullName>
        <field>Run_Trigger__c</field>
        <literalValue>1</literalValue>
        <name>Run Trigger to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Marketing_Program_Leader_Email</fullName>
        <description>Update the Marketing Program Leader Email field when the Marketing Program Leader Email Formula field is updated</description>
        <field>Marketing_Program_Leader_Email__c</field>
        <formula>Marketing_Program_Leader_Email_Formula__c</formula>
        <name>Update Marketing Program Leader Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Email Marketing Program Leader</fullName>
        <actions>
            <name>Email_Marketing_Program_Leader</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Restrictions__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		Email_Marketing_Program_Leader_Summary__c = true, 		Marketing_Program_Leader_Email__c != null )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Primary RI AM Contact</fullName>
        <actions>
            <name>Email_Primary_RI_AM_Contact</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Restrictions__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),   Primary_RI_AM_contact_EA_or_AE_or_RM__c != null 		 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Run trigger after expiration date</fullName>
        <active>true</active>
        <description>the email alert &apos;Reminder that restrictions are about to expire&apos; should be added to this when activated post launch</description>
        <formula>AND(   Run_Trigger__c = FALSE,    Expiration_Date__c != null,    Expiration_Date__c &gt;= TODAY()   )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
