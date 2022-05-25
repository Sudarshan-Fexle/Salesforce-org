<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Compass_New_Ticket_Created</fullName>
        <description>Compass: New Ticket Created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Notify_Owner_that_record_has_been_created</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assigned_to_Contact_Email_Field_Update</fullName>
        <field>Assigned_To_Contact_Email__c</field>
        <formula>IF(  NOT( ISBLANK(Assigned_To_Contact__c) ),  Assigned_To_Contact__r.Email , &apos;&apos;)</formula>
        <name>Assigned to Contact Email Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_DateTime_Closed_Auto_Update</fullName>
        <field>Site_Issue_Close_Date__c</field>
        <formula>NOW()</formula>
        <name>Compass: Date-Time Closed Auto Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_FTP_ID</fullName>
        <field>FTP_ID__c</field>
        <formula>Compass_Support_Issue_Ticket__r.FTP_ID__c</formula>
        <name>Compass: Update FTP ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_IDN_Project_Key</fullName>
        <field>IDN_Project_Key__c</field>
        <formula>Compass_Support_Issue_Ticket__r.IDN_Project_Key__c</formula>
        <name>Compass: Update IDN Project Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Member_SK</fullName>
        <field>Member_SK__c</field>
        <formula>Compass_Support_Issue_Ticket__r.Member_SK__c</formula>
        <name>Compass: Update Member SK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_PCS_Project_Key</fullName>
        <description>Updates the PCS Project Key of the Implementation Ticket from the Support Issue Ticket</description>
        <field>PCS_Project_Key__c</field>
        <formula>Compass_Support_Issue_Ticket__r.PCS_Project_Key__c</formula>
        <name>Compass: Update PCS Project Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_IE_Team_MS_Owners</fullName>
        <description>Created for CR-20151116-9383.</description>
        <field>OwnerId</field>
        <lookupValue>IE_Team_MS_Owners</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_IE_Team_MS_Owners</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_MS_Update_Owner_CSupport_Issue_Que</fullName>
        <description>Created for the CR-20150728-9104.</description>
        <field>OwnerId</field>
        <lookupValue>Compass_Support_Issue_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_MS_Update_ Owner_ CSupport_Issue_Que</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateOwnerWithCompassSupportIssueQ</fullName>
        <field>OwnerId</field>
        <lookupValue>Compass_Support_Issue_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_PopulateOwnerWithCompassSupportIssueQ</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateRMSMemberWithTrue</fullName>
        <field>RMS_Member__c</field>
        <literalValue>1</literalValue>
        <name>FU_ PopulateRMSMemberWithTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateMSOwnerToChrisSanford</fullName>
        <field>OwnerId</field>
        <lookupValue>Compass_Data_Analytics</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>UpdateMSOwnerToCompassDataAnalyticsQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateOwnerToRMSQueue</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_7_USC_RMS</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_ UpdateOwnerToRMSQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Support_Date_Time_Opened</fullName>
        <field>Site_Issue_Created_Date__c</field>
        <formula>NOW()</formula>
        <name>Member Support: Date/Time Opened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_1</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_1_EBDI_NUBI</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_2</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_2_Intl_Spend_Surgery_ED</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_3</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_3_SP_Spend_SCI</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_4</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_4_USC</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Autopopulate CS Implementation off CS Support Issue</fullName>
        <actions>
            <name>Compass_Update_FTP_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Compass_Update_IDN_Project_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Compass_Update_Member_SK</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Compass_Update_PCS_Project_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This autopoulates several Implementation fields based off the Support Issue Ticket listed on the record.</description>
        <formula>( ( $RecordType.Name = &quot;Compass Implementation &amp; Support&quot; ) &amp;&amp; (NOT(ISNULL(Compass_Support_Issue_Ticket__c))) &amp;&amp; (ISPICKVAL( Compass_Support_Issue_Ticket__r.Support_Category__c , &quot;New Member Set-Up&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass Implementation %26 Support%3A Set Owner Support Queue</fullName>
        <actions>
            <name>FU_MS_Update_Owner_CSupport_Issue_Que</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>equals</operation>
            <value>User Management</value>
        </criteriaItems>
        <description>Applies to Compass Implementation &amp; Support.  When Support Category is &quot;User Management&quot;, assign the owner to Compass Support Issue Queue.  Created via CR-9104</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Assign owner to Compass Support Queue</fullName>
        <actions>
            <name>FU_PopulateOwnerWithCompassSupportIssueQ</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Support Issue</value>
        </criteriaItems>
        <description>Applies to Compass Support Issue record type.  Assign Compass Support Issue Queue as the owner of new or updated records when the Record Type is Compass Support Issue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Auto Update Date%2FTime Closed</fullName>
        <actions>
            <name>Compass_DateTime_Closed_Auto_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>10-Closed,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Connect Ticket,Compass Data Analytics Ticket,Compass Implementation &amp; Support,CCA Data Load,Crimson Support Request</value>
        </criteriaItems>
        <description>This rule autopopulates the Date/Time Closed field on Compass records when the Ticket is marked as &quot;Complete&quot; in the &quot;Status&quot; field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Auto Update Date%2FTime Opened</fullName>
        <actions>
            <name>Member_Support_Date_Time_Opened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>contains</operation>
            <value>Compass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Report Request,Internal Initiative,Internal Initiative Detail,CPRM Data Load</value>
        </criteriaItems>
        <description>This rule autopopulates the Date/Time Opened field on Compass records when the Ticket is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A New Ticket Created</fullName>
        <actions>
            <name>Compass_New_Ticket_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Applies to Compass Connect Ticket,Compass Data Analytics Ticket,Compass Implementation &amp; Support.  Whena record is created with Support Category populated, send an email alert to the Owner.</description>
        <formula>AND (   NOT(  AND(  $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,  OR(  CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Site_Issue__c&quot;),  CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)  )  )  ),  OR (  RecordType.DeveloperName = &apos;Compass_Connect_Ticket&apos;,  RecordType.DeveloperName = &apos;Compass_Data_Analytics_Ticket&apos;,  RecordType.DeveloperName = &apos;Compass_Implementation&apos;,  RecordType.DeveloperName = &apos;Compass_Support_Issue&apos;  ),   NOT(ISPICKVAL(Support_Category__c, &apos;&apos;))  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Compass- EDBI_NUBI - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>EDBI,NUBI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Assign_an_Individual_Owner__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Update owner to MS Queue 1 - EBDI, NUBI when Deployment Type is EDBI,NUBI, Record Type is Compass Implementation &amp; Support, and Assign an Individual Owner is false.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- International Spend_International Surgery_International ED - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>International Spend,International Surgery,International ED</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Assign_an_Individual_Owner__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Update the Owner to MS Queue 2 - Intl Spend, Surgery &amp; ED when Deployment Type is International Spend,International Surgery,International ED, Record Type is Compass Implementation &amp; Support, and Assign an Individual Owner is false.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Surgical Profitability_Spend_SCI - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   Deployment__r.Clarizen_Product__c == &quot;Cost and Ops&quot;,   RecordType.Name == &quot;Compass Implementation &amp; Support&quot;,   Assign_an_Individual_Owner__c == false )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- USC - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>USC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Assign_an_Individual_Owner__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Update the Owner to MS Queue 4 - USC when Deployment Type is USC, Record Type is Compass Implementation &amp; Support, and Assign an Individual Owner = false.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internal Initiative- Date Closed Autofill</fullName>
        <actions>
            <name>Compass_DateTime_Closed_Auto_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>06 - Issue Resolved - Ticket Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Initiative Detail</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Member Support%3A Check if Date%2FTime Opened is null</fullName>
        <active>true</active>
        <description>This will be only executed only at the time of record creation. Workflow will check if Date/Time Opened is null, then update the “Date/Time Opened” field with current date time(formula = NOW()) using a field update.</description>
        <formula>Site_Issue_Created_Date__c &lt; NOW ()</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Assigned To Contact Email</fullName>
        <actions>
            <name>Assigned_to_Contact_Email_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_AssignMSToRMS</fullName>
        <actions>
            <name>FU_UpdateOwnerToRMSQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RMS_Member__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>USC</value>
        </criteriaItems>
        <description>When RMS Member is true and Deployment Type is USC, assign to MS Queue 7 - USC RMS queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_IE_Team_MS_Date_Time_Closed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>IE Team Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Created for  CR-20151116-9383.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_IE_Team_MS_Owners</fullName>
        <actions>
            <name>FU_IE_Team_MS_Owners</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>IE Team Support</value>
        </criteriaItems>
        <description>Created for  CR-20151116-9383.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulateRMSMemberWithTrue</fullName>
        <actions>
            <name>FU_PopulateRMSMemberWithTrue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set RMS Member to true when the record is created if the related Program&apos;s Acronym is &quot;BHSM&quot; and the Deployment&apos;s RMS Member is true.</description>
        <formula>AND(     Deployment__r.RMS_Member__c  = true,      Project__r.Product__r.Program_Acronym__c = &apos;BHSM&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateMSDataAnalyticsTicketOwner</fullName>
        <actions>
            <name>FU_UpdateMSOwnerToChrisSanford</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Data Analytics Ticket</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
