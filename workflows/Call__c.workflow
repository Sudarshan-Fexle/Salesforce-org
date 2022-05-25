<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>E_Mail_call_notes_to_creator</fullName>
        <description>E-Mail call notes to creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/E_Mail_call_notes_to_creator</template>
    </alerts>
    <alerts>
        <fullName>Ref_Req_Current_Status_set_as_Scheduled_EA</fullName>
        <description>Ref Req: Current Status set as Scheduled EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>shimpt@advisory.com.abc.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Project_DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Ref_Req_Current_Status_Scheduled</template>
    </alerts>
    <alerts>
        <fullName>Ref_Req_Notify_Assigned_To_of_new_Record</fullName>
        <description>Ref Req: Notify Assigned To of new Record</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Ref_Req_Created_record_notify_Marketer</template>
    </alerts>
    <alerts>
        <fullName>Ref_Req_Notify_DA_of_record_creation</fullName>
        <description>Ref Req: Notify DA of record creation</description>
        <protected>false</protected>
        <recipients>
            <field>Project_DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Ref_Req_Created_record_notify_DA</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_Original_BA</fullName>
        <field>Original_BA__c</field>
        <formula>null/*Member__r.Recurring_Business_Analyst__r.FirstName &amp;amp; &amp;apos;  &amp;apos; &amp;amp; Member__r.Recurring_Business_Analyst__r.LastName*/</formula>
        <name>Populate Original BA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Original_DA</fullName>
        <field>Original_DA__c</field>
        <formula>Member__r.Dedicated_Advisor__r.FirstName &amp; &apos; &apos; &amp;  Member__r.Dedicated_Advisor__r.LastName</formula>
        <name>Populate Original DA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Project%3A Populate Original BA %26 DA</fullName>
        <actions>
            <name>Populate_Original_BA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Original_DA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.Project_Name__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Ref Req%3A Notify DA</fullName>
        <actions>
            <name>Ref_Req_Notify_DA_of_record_creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-3833. This email alert will notify the DA when the record is created.</description>
        <formula>AND (      					NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Call__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 					RecordType.DeveloperName = &apos;Reference_Call&apos;	     	 	)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
