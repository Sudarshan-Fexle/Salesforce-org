<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CR_Deployed_Inform_Requester</fullName>
        <description>CR Deployed Inform Requester</description>
        <protected>false</protected>
        <recipients>
            <field>Stakeholder__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>applicationsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>eTech_Dev_Triage_Cases_Support/Change_Request_Deployed</template>
    </alerts>
    <alerts>
        <fullName>CaseReceived_TicketCreatedNotification</fullName>
        <description>Case Received/Ticket Created Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>applicationsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>eTech_Dev_Triage_Cases_Support/Case_Received</template>
    </alerts>
    <alerts>
        <fullName>Case_Closed_Submit_a_new_case_Starfish</fullName>
        <description>Case Closed - Submit a new case (Starfish)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>starfishsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_customer_notification_to_create_a_new_case_HE_Admissions_Naviance</template>
    </alerts>
    <alerts>
        <fullName>Case_Deadline_Changed_Email_Alert</fullName>
        <description>Case: Deadline Changed Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Expert_Center/Case_Deadline_has_changed</template>
    </alerts>
    <alerts>
        <fullName>Case_closed_open_a_new_case</fullName>
        <description>Case Closed - Submit a new case (HE and K12)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/CST_customer_notification_to_create_a_new_case_HE_Admissions_Naviance</template>
    </alerts>
    <alerts>
        <fullName>Case_edited_and_owner_is_inactive</fullName>
        <description>Case edited and owner is inactive</description>
        <protected>false</protected>
        <recipients>
            <recipient>Inactive_Case_Owner_Notification</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Templates/CST_Case_Edited_and_Owner_is_Inactive</template>
    </alerts>
    <alerts>
        <fullName>Client_Notification_Case_Comment_Intersect2</fullName>
        <description>Client Notification Case Comment (Intersect)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>agreene@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Case_Owner_2__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>compasssupport@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/Case_Comment_Notification_Naviance</template>
    </alerts>
    <alerts>
        <fullName>Client_Notification_Case_Comment_Starfish</fullName>
        <description>Client Notification Case Comment (Starfish)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>starfishsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/Compass_Case_Comment</template>
    </alerts>
    <alerts>
        <fullName>Closed_Cappex_Case</fullName>
        <description>Closed Cappex Case</description>
        <protected>false</protected>
        <recipients>
            <field>Cappex_Partner_Success_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Closed_Cappex_Case</template>
    </alerts>
    <alerts>
        <fullName>Created_Cappex_Case</fullName>
        <description>Created Cappex Case</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Cappex_Partner_Success_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Created_Cappex_Case</template>
    </alerts>
    <alerts>
        <fullName>EA_CASE_STATUS_PAGE_EMAIL_ALERT</fullName>
        <description>EA_CASE_STATUS_PAGE_EMAIL_ALERT</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ET_CASE_STATUS_PAGE_EMAIL_NOTES</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_Case_External</fullName>
        <description>Email Alert: Case External Event Request</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>sfadmin@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Events_Member_Support/Case_Response_Email_External_Event_Request</template>
    </alerts>
    <alerts>
        <fullName>Email_Case_Details_to_Creator</fullName>
        <description>Email Case Details to Creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Expert_Center_Case_Details</template>
    </alerts>
    <alerts>
        <fullName>Email_the_Account_Manager_that_a_new_Case_is_created</fullName>
        <description>Email the Account Manager that a new Case is created</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>HE_Email_Templates/New_Case_notification_for_Account_Manager</template>
    </alerts>
    <alerts>
        <fullName>Grad_Year_Update_for_EO_Clients</fullName>
        <description>Grad Year Update for EO Clients</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>chunter@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mrubindecelis@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Cappex_Email_Templates/Grad_Year_EO_Update</template>
    </alerts>
    <alerts>
        <fullName>Intersect_Close_Case_Email_Notifciation_for_Account_Manager</fullName>
        <description>Intersect - Close Case Email Notifciation for Account Manager</description>
        <protected>false</protected>
        <recipients>
            <field>Intersect_Partner_Success_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>HE_Email_Templates/HE_Close_Case_Email_Notification_for_Account_Manager</template>
    </alerts>
    <alerts>
        <fullName>Member_Facing_Issue</fullName>
        <description>Member-Facing Issue</description>
        <protected>false</protected>
        <recipients>
            <field>Support_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>applicationsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>eTech_Dev_Triage_Cases_Support/Member_Facing_Issue_Submitted</template>
    </alerts>
    <alerts>
        <fullName>New_Case_Submitted</fullName>
        <description>New Case Submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>StarfishCase</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>starfishsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>HE_Email_Templates/New_Case_Submitted</template>
    </alerts>
    <alerts>
        <fullName>Pending_Client_Confirmation_120_hours_HE</fullName>
        <description>Pending Client Confirmation - 120 hours (HE)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>starfishsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Pending_Client_Notification_120_hours_HE</template>
    </alerts>
    <alerts>
        <fullName>Pending_Client_Confirmation_24_72_hours_HE</fullName>
        <description>Pending Client Confirmation - 24/72 hours (HE)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>starfishsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Pending_Client_Notification_24_72_hours_HE</template>
    </alerts>
    <alerts>
        <fullName>Waiting_on_Client_Notification_14_days_Counselor_Community</fullName>
        <description>Waiting on Client Notification - 14 days (Counselor Community)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>counselorcommunity@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Waiting_on_Client_Notification_168_hours_Intersect_Counselor_Community</template>
    </alerts>
    <alerts>
        <fullName>Waiting_on_Client_Notification_14_days_Intersect</fullName>
        <description>Waiting on Client Notification -  14 days (Intersect)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>intersectsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Waiting_on_Client_Notification_168_hours_Intersect_Counselor_Community</template>
    </alerts>
    <alerts>
        <fullName>Waiting_on_Client_Notification_168_HE_and_K12</fullName>
        <description>Waiting on Client Notification - 14 days (HE and K12)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>starfishsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Waiting_on_Client_Notification_168_hours_HE_Naviance</template>
    </alerts>
    <alerts>
        <fullName>Waiting_on_Client_Notification_3_and_7_days_Counselor_Community</fullName>
        <description>Waiting on Client Notification - 3 and 7 days (Counselor Community)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>counselorcommunity@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Waiting_on_Client_Notification_3_and_7_days_Intersect_Counselor_Community</template>
    </alerts>
    <alerts>
        <fullName>Waiting_on_Client_Notification_3_and_7_days_Intersect</fullName>
        <description>Waiting on Client Notification - 3 and 7 days (Intersect)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>intersectsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Waiting_on_Client_Notification_3_and_7_days_Intersect_Counselor_Community</template>
    </alerts>
    <alerts>
        <fullName>Waiting_on_Client_Notification_48_96_HE_and_K12</fullName>
        <description>Waiting on Client Notification - 3 and 7 days (HE and K12)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>starfishsupport@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/CST_Waiting_on_Client_Notification_48_96_hours_HE_Naviance</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Owner_Queue_Transfer_FU</fullName>
        <field>Status</field>
        <literalValue>Transferred</literalValue>
        <name>Case Owner Queue Transfer FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Set_Status_when_Assigned</fullName>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>Case: Set Status when Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Substatus_set_to_null</fullName>
        <description>Created as part of CR-8705</description>
        <field>Sub_Status__c</field>
        <name>Case Substatus set to null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_To_Waiting_For_CR_Deploy</fullName>
        <field>Status</field>
        <literalValue>Awaiting Change Request Deployment</literalValue>
        <name>Change Status To Waiting For CR Deploy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_In_Progress</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Change Status to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_case_closed_notification_to_true</fullName>
        <field>Case_Closed_Notification_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Check case closed notification to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Last_Updated</fullName>
        <field>Date_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Date Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_CaseOrigin</fullName>
        <field>Origin</field>
        <literalValue>Partner Portal</literalValue>
        <name>FU_CaseOrigin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Case_Status_Change_Date</fullName>
        <field>Status_Changed_Date__c</field>
        <formula>TODAY()</formula>
        <name>FU Case Status Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Case_support_manager</fullName>
        <description>Update Case Support Manager to Karl Brenneman</description>
        <field>Support_Manager__c</field>
        <lookupValue>kbrenneman@eab.com.eab</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>FU_Case_support_manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Populate_Account_Type_On_Case</fullName>
        <description>Created for CR-20170222-10715</description>
        <field>Account_Type__c</field>
        <formula>Text(Account.Strategic_Account_Segment__c)</formula>
        <name>FU_Populate_Account_Type_On_Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UPDATE_NEW_MEMBER_FIRST_CASE</fullName>
        <description>Created for CR-20160726-10065.</description>
        <field>New_Member_s_First_Case__c</field>
        <literalValue>1</literalValue>
        <name>FU_UPDATE_NEW _MEMBER_FIRST_CASE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Priority_to_Minor</fullName>
        <field>Priority</field>
        <literalValue>Minor</literalValue>
        <name>Set Case Priority to Minor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Starfish_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Starfish_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Starfish Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Starfish_Support_Product</fullName>
        <description>Updates the Support Product field to starfish if case record type equals starfish</description>
        <field>Support_Product__c</field>
        <literalValue>Starfish</literalValue>
        <name>Starfish Support Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Last_Case_Support_Rep_Comment</fullName>
        <field>Last_Support_Rep_Comment__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Last Case Support Rep Comment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseReason</fullName>
        <field>Reason</field>
        <literalValue>No Response</literalValue>
        <name>UpdateCaseReason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Origin_to_Voicemail</fullName>
        <field>Origin</field>
        <literalValue>Voice Mail</literalValue>
        <name>Update Case Origin to Voicemail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Record_Type_to_Intersect_APS</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Intersect_APS</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Case Record Type to Intersect APS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_Closed</fullName>
        <description>Updates case status to closed if client has not responded within 120 hours.</description>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Update Case Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_Application_Support</fullName>
        <description>set case to type applicaiton support</description>
        <field>Type</field>
        <literalValue>Application Support</literalValue>
        <name>Update Case Type: Application Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_Workday_Integration</fullName>
        <field>Type</field>
        <literalValue>Workday Integration</literalValue>
        <name>Update Case Type: Workday Integration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Requested_Completion_Date_FU</fullName>
        <description>Created as part of CR-8705</description>
        <field>Requested_Completion_Date__c</field>
        <formula>TODAY() + 8</formula>
        <name>Update Requested Completion Date FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_case_status_Fullfilled_by_TS</fullName>
        <field>Status</field>
        <literalValue>Fulfilled by Technical Support</literalValue>
        <name>Update case status - Fullfilled by TS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Case_Closed_Date_Time_30</fullName>
        <field>Closed_Date_Time_30_Days__c</field>
        <formula>ClosedDate + 30</formula>
        <name>Update the Case Closed Date &amp; Time + 30</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_APS_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>APS_Review</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update to APS Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Fulfilled_by_Technical_Support</fullName>
        <field>Status</field>
        <literalValue>Fulfilled by Technical Support</literalValue>
        <name>Update to Fulfilled by Technical Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Need_More_Information</fullName>
        <field>Status</field>
        <literalValue>Need More Information</literalValue>
        <name>Update to Need More Information</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Starfish_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Starfish</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update to Starfish Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updates_case_closed_date_time</fullName>
        <description>Updates closed date 7 time of a case to today + 7 days</description>
        <field>Closed_Date_Time_14_Days__c</field>
        <formula>ClosedDate + 14</formula>
        <name>Updates case closed date &amp; time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updates_case_closed_date_time_30_day</fullName>
        <field>Closed_Date_Time_30_Days__c</field>
        <formula>ClosedDate + 30</formula>
        <name>Updates case closed date &amp; time + 30 day</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Account Manager Close Case Email Notification %28Intersect%29</fullName>
        <actions>
            <name>Intersect_Close_Case_Email_Notifciation_for_Account_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email notification to the account manager when  an Technical Support case has closed.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND( OR( RecordType.DeveloperName = &quot;Intersect_APS&quot;, RecordType.DeveloperName = &quot;Intersect&quot;) , ISPICKVAL( Status , &quot;Closed&quot;), NOT(ISBLANK( Intersect_Partner_Success_Manager_Email__c )) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Received%2FTicket Created Notification</fullName>
        <actions>
            <name>CaseReceived_TicketCreatedNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Sent to Contact submitting new Case with record type of eTech Support</description>
        <formula>AND (       NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 					RecordType.DeveloperName = &apos;eTech_Support&apos;	     	)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Status Changed Date</fullName>
        <actions>
            <name>FU_Case_Status_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20170420-10865</description>
        <formula>ISCHANGED(Status)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case edited and owner is inactive %28HE%29</fullName>
        <actions>
            <name>Case_edited_and_owner_is_inactive</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow sends a notification to Kerri when a case has been edited and the owner is inactive.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND (  ISCHANGED (Status ), NOT( ISPICKVAL( Status , &quot;Closed&quot;)),  Owner:User.IsActive = False,   Account.RecordType.DeveloperName = &quot;US_Education&quot;,  OR(  RecordType.DeveloperName =&quot;APS_Review&quot;,  RecordType.DeveloperName =&quot;Technical_Support&quot;)) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Deadline has changed</fullName>
        <actions>
            <name>Case_Deadline_Changed_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  				NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 				BEGINS( OwnerId ,&quot;005&quot;) ,  LastModifiedById &lt;&gt; OwnerId , NOT( ISNULL( PRIORVALUE( Deadline__c ) ) ) , ISCHANGED( Deadline__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Set Status when Assigned</fullName>
        <actions>
            <name>Case_Set_Status_when_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Assigned To is populated the status moves to Assigned.</description>
        <formula>AND(   BEGINS(OwnerId, &quot;005&quot;),   ISPICKVAL(Status, &quot;New Request&quot;),   RecordType.DeveloperName != &quot;Event_Request&quot;, RecordType.DeveloperName != &apos;Cappex_Requests&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Status to In Progress</fullName>
        <actions>
            <name>Change_Status_to_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( 
 NOT( 
  AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, 
   OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), 
   CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  
   
   (  
   ISCHANGED(OwnerId) &amp;&amp; 
   !CONTAINS(OwnerId, &apos;00G&apos;) &amp;&amp; 
   OR((ISPICKVAL(Status, &apos;New Request&apos;) &amp;&amp; RecordType.DeveloperName = &apos;Cappex_Requests&apos;),
      ( ISPICKVAL(Status, &apos;New&apos;) &amp;&amp; OR(RecordType.DeveloperName = &apos;Starfish&apos;, RecordType.DeveloperName =&apos;Intersect&apos;,RecordType.DeveloperName = &apos;Intersect_APS&apos;, RecordType.DeveloperName = &apos;Counselor_Community&apos;))
     )
    
   ) 
   
 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Client Notification Case Comment %28Starfish%29</fullName>
        <actions>
            <name>Client_Notification_Case_Comment_Starfish</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Uncheck_Last_Case_Support_Rep_Comment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Last_Support_Rep_Comment__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>APS Review,Starfish,Technical Support</value>
        </criteriaItems>
        <description>This workflow sends a notification to the client when latest support rep comment has been set to true. It also unchecks this field after email has been sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Closed Cappex Case</fullName>
        <actions>
            <name>Closed_Cappex_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created via CR-20201207-14726</description>
        <formula>AND(NOT( ISBLANK(RecordTypeId)), RecordType.DeveloperName = &apos;Cappex_Requests&apos;, IsClosed = true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Creation of Cappex Case</fullName>
        <actions>
            <name>Created_Cappex_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20201207-14726</description>
        <formula>AND(NOT( ISBLANK( RecordTypeId ) ), RecordType.DeveloperName = &apos;Cappex_Requests&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EO Grad Year Update for Marketing</fullName>
        <actions>
            <name>Grad_Year_Update_for_EO_Clients</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Send_Email_notification_to_Marketing__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Case Details to Creator</fullName>
        <actions>
            <name>Email_Case_Details_to_Creator</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Rule for Email Case Details to Creator</description>
        <formula>AND (     NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		Email_Case_Details_to_Creator__c = true 	 	 	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Etech%3A Queue Transfer</fullName>
        <actions>
            <name>Case_Owner_Queue_Transfer_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Substatus_set_to_null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-8705</description>
        <formula>AND (  	OR ( 		RecordType.DeveloperName = &quot;eTech_Support&quot;,  		RecordType.DeveloperName=&quot;WebHelp&quot; 	),  	ISCHANGED(OwnerId),  	NOT(ISBLANK(Owner:Queue.Id))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Etech%3A Update Requested Completion Date</fullName>
        <actions>
            <name>Update_Requested_Completion_Date_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transferred</value>
        </criteriaItems>
        <description>Created as part of CR-8705</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fulfilled by APS %28Starfish%29</fullName>
        <actions>
            <name>Update_to_Starfish_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Fulfilled by APS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Support_Product__c</field>
            <operation>equals</operation>
            <value>Degree Planner,Starfish,Starfish - Analytics,Starfish - Integrations,Starfish - SSMx</value>
        </criteriaItems>
        <description>Updates record type to Starfish when status equals Fulfilled by APS and support product is Degree Planner or Starfish.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>K12 - Update Case Record Type to Intersect APS</fullName>
        <actions>
            <name>Update_Case_Record_Type_to_Intersect_APS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates record type to Intersect APS if case record type is Intersect and status is Escalated to APS.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (   ISPICKVAL(Status, &apos;Escalated to APS&apos;) &amp;&amp; OR(RecordType.DeveloperName = &apos;Intersect&apos;, RecordType.DeveloperName = &apos;Counselor_Community&apos;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to client case is closed %28Intersect%2C Counselor Community%29</fullName>
        <actions>
            <name>Case_closed_open_a_new_case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_case_closed_notification_to_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notifies client case has been closed for more than 14 days and to create a new case.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND(  NOT(ISBLANK( Email_Comment_Post_14_days__c )), Case_Closed_Notification_Sent__c = FALSE , OR( RecordType.DeveloperName = &quot;Counselor_Community&quot;, RecordType.DeveloperName = &quot;Intersect&quot;, RecordType.DeveloperName = &quot;Intersect_APS&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to client case is closed %28Starfish%29</fullName>
        <actions>
            <name>Case_Closed_Submit_a_new_case_Starfish</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_case_closed_notification_to_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notifies client case has been closed for more than 14 days and to create a new case.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND(  NOT(ISBLANK( Email_Comment_Post_14_days__c )), OR( RecordType.DeveloperName = &quot;APS_Review&quot;, RecordType.DeveloperName = &quot;Starfish&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pending Client Confirmation %28Starfish%29</fullName>
        <active>true</active>
        <description>This workflow sends a notification to the client work has been completed and support specialist is awaiting their feedback.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND( OR( RecordType.DeveloperName = &quot;APS_Review&quot;, RecordType.DeveloperName = &quot;Starfish&quot;) , ISPICKVAL( Status , &quot;Pending Client Confirmation&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Pending_Client_Confirmation_24_72_hours_HE</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Pending_Client_Confirmation_120_hours_HE</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Update_Case_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <timeLength>120</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Populate Support Manager</fullName>
        <actions>
            <name>FU_Case_support_manager</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Support</value>
        </criteriaItems>
        <description>When a Case Created of etech Support record type then stamp Karl Brenneman as a Support Manager</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SC-New Case Submitted</fullName>
        <actions>
            <name>New_Case_Submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>When case record type is Starfish or support product is Starfish, notification is sent to Starfish case group.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  ( OR( RecordType.DeveloperName = &quot;Starfish&quot; , ISPICKVAL( Support_Product__c , &quot;Starfish&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SC-Notify the Account Owner when a Case is created %28HE%29</fullName>
        <actions>
            <name>Email_the_Account_Manager_that_a_new_Case_is_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 and 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>APS Review,Starfish</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.OwnerId</field>
            <operation>notEqual</operation>
            <value>System Admin</value>
        </criteriaItems>
        <description>When a new case is created, notify that Case&apos;s Account Manager</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SC-Starfish Product field update</fullName>
        <actions>
            <name>Starfish_Support_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Auto populates the &quot;Support Product&quot; field on cases</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (   AND(RecordType.DeveloperName =&quot;Starfish&quot; &amp;&amp; NOT(OR(ISPICKVAL(Status, &apos;Careers&apos;), ISPICKVAL(Status, &apos;Degree Planner&apos;),ISPICKVAL(Status, &apos;Starfish - Analytics&apos;),ISPICKVAL(Status, &apos;Starfish - Integrations&apos;),ISPICKVAL(Status, &apos;Starfish - SSMx&apos;))) )) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Case Origin to Minor upon Case Creation</fullName>
        <actions>
            <name>Set_Case_Priority_to_Minor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  OR(  RecordType.DeveloperName =&quot;Intersect&quot;,  RecordType.DeveloperName =&quot;Intersect_APS&quot;,RecordType.DeveloperName =&quot;Counselor_Community&quot;,RecordType.DeveloperName =&quot;Starfish&quot;) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Starfish Case Assigned to Starfish Queue</fullName>
        <actions>
            <name>Starfish_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will send any Starfish case when created to the Starfish queue.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  ( OR( RecordType.DeveloperName = &quot;Starfish&quot; , ISPICKVAL( Support_Product__c , &quot;Starfish&quot;) ) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Status - Update field %22Date Last Updated%22</fullName>
        <actions>
            <name>Date_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED( Status ), ISCHANGED( Sub_Status__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status Change If change Request Created</fullName>
        <actions>
            <name>Change_Status_To_Waiting_For_CR_Deploy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( 					 					NOT(ISBLANK(Change_Request__c)),       RecordType.Name = &apos;eTech Support&apos;,      NOT(ISPICKVAL(Resolution__c, &quot;CR Deployed&quot;)), NOT(ISPICKVAL(Change_Request__r.Status__c , &quot;12-Deployed&quot;))    						 					)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Technical Support - L2 Status Completed by Engineering</fullName>
        <actions>
            <name>Update_to_APS_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates original case status to Completed by Engineering and record type to APS when L2 Status is updated to Completed by Engineering for Technical Support case record types.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND(RecordType.DeveloperName =&quot;Technical_Support&quot;,ISPICKVAL(Technical_Support_Status__c,&quot;Completed by Engineering&quot;)) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Technical Support - L2 Status Fulfilled by Technical Support %28APS%29</fullName>
        <actions>
            <name>Update_case_status_Fullfilled_by_TS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_to_APS_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates original case status to Fulfilled by Technical Support and record type to APS when L2 Status is updated to Fulfilled by Technical Support and GD Bug or Task equals Bug.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND(RecordType.DeveloperName =&quot;Technical_Support&quot;,ISPICKVAL(Technical_Support_Status__c,&quot;Fulfilled by Technical Support&quot;),ISPICKVAL(GD_Bug_or_Task__c,&quot;Bug&quot;)) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Technical Support - L2 Status Fulfilled by Technical Support %28Starfish%29</fullName>
        <actions>
            <name>Update_to_Fulfilled_by_Technical_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_to_Starfish_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates original case status to Fulfilled by Technical Support and record type to Starfish when L2 Status is updated to Fulfilled by Technical Support and GD Bug or Task equals Task.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND(RecordType.DeveloperName =&quot;Technical_Support&quot;,ISPICKVAL(Technical_Support_Status__c,&quot;Fulfilled by Technical Support&quot;),ISPICKVAL(GD_Bug_or_Task__c,&quot;Task&quot;), OR(ISPICKVAL(Support_Product__c,&quot;Starfish&quot;),ISPICKVAL(Support_Product__c,&quot;Degree Planner&quot;),ISPICKVAL(Support_Product__c,&quot;Starfish - Analytics&quot;),ISPICKVAL(Support_Product__c,&quot;Starfish - Integrations&quot;),ISPICKVAL(Support_Product__c,&quot;Starfish - SSMx&quot;)) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Technical Support - L2 Status Need More Information %28APS%29</fullName>
        <actions>
            <name>Update_to_APS_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_to_Need_More_Information</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates original case status to Escalated to APS and record type to APS when L2 Status is updated to Need More Information</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND(RecordType.DeveloperName =&quot;Technical_Support&quot;,ISPICKVAL(Technical_Support_Status__c,&quot;Need More Information&quot;),ISPICKVAL(GD_Bug_or_Task__c,&quot;Bug&quot;)) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Origin to Voicemail</fullName>
        <actions>
            <name>Update_Case_Origin_to_Voicemail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Intersect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>unityconnection@cvg-ucxn-01.hobsons.local</value>
        </criteriaItems>
        <description>Workflow updates Intersect case origin to Voicemail if case webmail is unityconnection@cvg-ucxn-01.hobsons.local.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Type%3A Application Support</fullName>
        <actions>
            <name>Update_Case_Type_Application_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email to Case: Application Support,Email to Case: SF Help,Email to Case: IS Dev</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Type%3A Workday Integration</fullName>
        <actions>
            <name>Update_Case_Type_Workday_Integration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email to Case: Workday Integration</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update the Case Closed Date %26 Time %2B 14 Days</fullName>
        <actions>
            <name>Updates_case_closed_date_time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Updates_case_closed_date_time_30_day</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When case is closed, updates closed date &amp; time to today + 14 days</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND( OR( RecordType.DeveloperName = &quot;APS_Review&quot;, RecordType.DeveloperName = &quot;Starfish&quot;, RecordType.DeveloperName = &quot;Technical_Support&quot;, RecordType.DeveloperName = &quot;Intersect&quot;, RecordType.DeveloperName = &quot;Counselor_Community&quot;) , ISPICKVAL( Status , &quot;Closed&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update the Case Closed Date %26 Time %2B 30 Days</fullName>
        <actions>
            <name>Update_the_Case_Closed_Date_Time_30</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When case is closed, updates closed date &amp; time to today + 30 days</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND( RecordType.DeveloperName = &quot;Projects&quot; , ISPICKVAL( Status , &quot;Closed&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF Rule%3A External Event Request</fullName>
        <actions>
            <name>Email_Alert_Case_External</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>External Event Request</value>
        </criteriaItems>
        <description>Send automatic response to Case creator when Record Type=External Event Request</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF-Member Facing Issue</fullName>
        <actions>
            <name>Member_Facing_Issue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Member_Impacting__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted,In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_CASE_STATUS_PAGE_EMAIL_NOTES</fullName>
        <actions>
            <name>EA_CASE_STATUS_PAGE_EMAIL_ALERT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Status Page Email Request</value>
        </criteriaItems>
        <description>Created for CR-20170526-10962.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_Populate_Account_Type_On_Case</fullName>
        <actions>
            <name>FU_Populate_Account_Type_On_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20170222-10715</description>
        <formula>NOT(ISNULL(AccountId))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_UPDATE_NEW _MEMBER_FIRST_CASE</fullName>
        <actions>
            <name>FU_UPDATE_NEW_MEMBER_FIRST_CASE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( 	Contact.TEC_Cases_Count__c = 1, 	NOT( 		ISBLANK(  New_Member_Programs_RI__c ) 		)  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateCaseOrigin</fullName>
        <actions>
            <name>FU_CaseOrigin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND(RecordType.DeveloperName =&quot;Starfish&quot;,ISPICKVAL( Origin ,&quot;&quot;)) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Waiting on Client %28Counselor Community%29</fullName>
        <active>true</active>
        <description>Sends notification to client when status is changed to Waiting on Client for Inersect cases. Client is sent a notification at 72 hours (3 days) and 168 hours (7 days). If no response is received, case auto closes at 336 hours (14 days).</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND( RecordType.DeveloperName = &quot;Counselor_Community&quot;, ISPICKVAL( Status , &quot;Waiting on Client&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_14_days_Counselor_Community</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>UpdateCaseReason</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Case_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_3_and_7_days_Counselor_Community</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_3_and_7_days_Counselor_Community</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Waiting on Client %28Intersect%29</fullName>
        <active>true</active>
        <description>Sends notification to client when status is changed to Waiting on Client for Inersect cases. Client is sent a notification at 72 hours (3 days) and 168 hours (7 days). If no response is received, case auto closes at 336 hours (14 days).</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  ( AND( OR( RecordType.DeveloperName = &quot;Intersect_APS&quot;, RecordType.DeveloperName = &quot;Intersect&quot;) , ISPICKVAL( Status , &quot;Waiting on Client&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_3_and_7_days_Intersect</name>
                <type>Alert</type>
            </actions>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_3_and_7_days_Intersect</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_14_days_Intersect</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>UpdateCaseReason</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Case_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Waiting on Client %28Starfish%29</fullName>
        <active>true</active>
        <description>Sends notification to client when status is changed to Waiting on Client for HE cases. Client is sent a notification at 72 hours (3 days) and 168 hours (7 days). If no response is received, case auto closes at 336 hours (14 days).</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Case&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND( OR( RecordType.DeveloperName = &quot;APS_Review&quot;, RecordType.DeveloperName = &quot;Technical_Support&quot;, RecordType.DeveloperName = &quot;Starfish&quot;) , ISPICKVAL( Status , &quot;Waiting on Client&quot;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UpdateCaseReason</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Case_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_48_96_HE_and_K12</name>
                <type>Alert</type>
            </actions>
            <timeLength>144</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_48_96_HE_and_K12</name>
                <type>Alert</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_48_96_HE_and_K12</name>
                <type>Alert</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Waiting_on_Client_Notification_168_HE_and_K12</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
