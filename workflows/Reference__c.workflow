<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Reference_Approval_Notification_Email_Alert</fullName>
        <description>Reference Approval Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Response_Notification</template>
    </alerts>
    <alerts>
        <fullName>Reference_Vetted_Notification</fullName>
        <description>Reference Vetted Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Vetted_Notification</template>
    </alerts>
    <alerts>
        <fullName>Reminder_to_setup_NASA_reference_vetting_call</fullName>
        <description>Reminder to setup NASA reference vetting call</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_360_Reference_Emails/NASA_P_AP_email_setting_up_a_reference_vetting_call</template>
    </alerts>
    <alerts>
        <fullName>Reminder_to_setup_reference_vetting_call</fullName>
        <description>Reminder to setup reference vetting call</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_360_Reference_Emails/Email_setting_up_a_reference_vetting_call</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_to_Vet_Approved</fullName>
        <field>Approval_to_Vet__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval to Vet Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_to_Vet_Denied</fullName>
        <field>Approval_to_Vet__c</field>
        <literalValue>Denied</literalValue>
        <name>Approval to Vet Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_to_Vet_Pending</fullName>
        <field>Approval_to_Vet__c</field>
        <literalValue>Pending</literalValue>
        <name>Approval to Vet Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Populate_ReferenceLevel_Display_Text</fullName>
        <description>Created for CR-20151216-9467.</description>
        <field>Reference_Level_Display_Text__c</field>
        <formula>IF(
 AND(
  !IsActive__c,
  !ISPICKVAL(Reference_Level__c,&quot;Pipeline&quot;)
 ),
 IF(
  !ISPICKVAL(Former_Reference_Level__c,&quot;&quot;),
  &quot;Former &quot;+TEXT(Former_Reference_Level__c),
  null
 ), 
 IF(
  ISPICKVAL(Reference_Level__c,&quot;Pipeline&quot;),
  &quot;Pipeline&quot;, 
  IF(
   IsActive__c, 
   CASE(
    Reference_Level__c, 
    &quot;Pipeline&quot;,&quot;Pipeline&quot;, 
    &quot;Gold Standard&quot;,&quot;Gold Standard&quot;, 
    &quot;Ambassador&quot;,&quot;Ambassador&quot;, 
    &quot;Participant&quot;, &quot;Participant&quot;,
    &quot;Graduate&quot;, &quot;Graduate&quot;,
    &quot;&quot;
   ),
   &quot;&quot;
  )
 )
)</formula>
        <name>FU_Populate_ReferenceLevel_Display_Text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Populate_Uses_Last_Quarter</fullName>
        <description>Created for CR-20160414-9766.</description>
        <field>Uses_Last_Quarter__c</field>
        <formula>Uses_This_Quarter__c</formula>
        <name>FU_Populate_Uses_Last_Quarter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Reset_Uses_This_Quarter</fullName>
        <description>Created for CR-20160414-9766.</description>
        <field>Uses_This_Quarter__c</field>
        <formula>0</formula>
        <name>FU_Reset_Uses_This_Quarter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Former_Reference_Level_Graduat</fullName>
        <description>Created for CR-20151216-9467.</description>
        <field>Former_Reference_Level__c</field>
        <literalValue>Graduate</literalValue>
        <name>FU_Update_Former_Reference_Level_Graduat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reference_Level_Blank</fullName>
        <field>Reference_Level__c</field>
        <name>Reference Level Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reference_Status_Unqualified</fullName>
        <field>Reference_Status__c</field>
        <literalValue>Not Referenceable</literalValue>
        <name>Reference Status Unqualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Reference_Status_Date</fullName>
        <field>Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Reference Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_Date</fullName>
        <field>Approval_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Approval Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Former_Ref_Level_Ambassador</fullName>
        <field>Former_Reference_Level__c</field>
        <literalValue>Ambassador</literalValue>
        <name>Update Former Ref Level Ambassador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Former_Ref_Level_Gold</fullName>
        <field>Former_Reference_Level__c</field>
        <literalValue>Gold Standard</literalValue>
        <name>Update Former Ref Level Gold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Promotion_Status_Date</fullName>
        <field>Promotion_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Promotion Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Date</fullName>
        <description>Update the status date to TODAY()</description>
        <field>Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Promotion Status Changed</fullName>
        <actions>
            <name>Update_Promotion_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Promotion Status Date when the Promotion Status changes</description>
        <formula>ISCHANGED( Promotion_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Approval to Vet Changed</fullName>
        <actions>
            <name>Update_Approval_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Approval Status Date when the Approval to Vet field is modified.</description>
        <formula>ISCHANGED( Approval_to_Vet__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Level Updated Ambassador</fullName>
        <actions>
            <name>Update_Former_Ref_Level_Ambassador</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Reference Level is changed from ‘Gold Standard’ or to ‘Ambassador’ then set Former Reference Level to ‘Ambassador’.</description>
        <formula>AND(   ISCHANGED(Reference_Level__c),     ISPICKVAL(Reference_Level__c, &quot;Ambassador&quot;),   OR(     ISPICKVAL(PRIORVALUE( Reference_Level__c ), &quot;Gold Standard&quot;),   ISPICKVAL(PRIORVALUE( Reference_Level__c ), &quot;Graduate&quot;)  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Level Updated Gold</fullName>
        <actions>
            <name>Update_Former_Ref_Level_Gold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Reference Level is changed from &lt;blank&gt; to ‘Gold Standard’, then set Former Reference Level to ‘Gold Standard’.</description>
        <formula>AND(   ISCHANGED(Reference_Level__c),   ISPICKVAL(Reference_Level__c, &quot;Gold Standard&quot;),   ISPICKVAL(PRIORVALUE( Reference_Level__c ), &quot;&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Level Updated Graduate</fullName>
        <actions>
            <name>FU_Update_Former_Reference_Level_Graduat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if the Reference Level is changed from &lt;blank&gt; or “Participant” to “Graduate”, then set Former Reference Level to ‘Graduate’. Created for CR-20151216-9467.</description>
        <formula>AND(     ISCHANGED(Reference_Level__c),  ISPICKVAL(Reference_Level__c, &quot;Graduate&quot;),  OR(   ISPICKVAL(PRIORVALUE( Reference_Level__c ), &quot;&quot;),   ISPICKVAL(PRIORVALUE( Reference_Level__c ), &quot;Participant&quot;)  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Module Created</fullName>
        <actions>
            <name>Update_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference__c.Status_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Executes when the reference module record is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Reference Status Changed</fullName>
        <actions>
            <name>Set_Reference_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Reference Status Date when the Reference Status changes</description>
        <formula>ISCHANGED( Reference_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Status Vetted or Unqualified</fullName>
        <actions>
            <name>Reference_Vetted_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Reference Status is changed to Vetted</description>
        <formula>AND ( 	  NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Reference__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 					OR ( 					    ISPICKVAL(Reference_Status__c, &apos;Vetted&apos;),          ISPICKVAL(Reference_Status__c, &apos;Not Referenceable&apos;)  					) 	 	 	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Populate_ReferenceLevel_Display_Text</fullName>
        <actions>
            <name>FU_Populate_ReferenceLevel_Display_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference__c.OwnerId</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Created for CR-20151216-9467.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
