<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EA_PT_Record_Set_to_Live_Proof_Status</fullName>
        <ccEmails>enrollmentservicesmailservices@eab.com</ccEmails>
        <description>EA_PT: Record Set to Live Proof Status</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/ET_PT_Record_Set_to_Live_Proof_Status</template>
    </alerts>
    <alerts>
        <fullName>PT_ACTUAL_DELIVERED_DATE_CHANGED_EMAIL_ALERT</fullName>
        <description>PT_ACTUAL_DELIVERED_DATE_CHANGED_EMAIL_ALERT</description>
        <protected>false</protected>
        <recipients>
            <recipient>Mailshop_Team</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Notify_Actual_Delivery_Date_Changed</template>
    </alerts>
    <alerts>
        <fullName>PT_ART_OUT_CHANGED_EMAIL_ALERT</fullName>
        <description>PT_ART_OUT_CHANGED_EMAIL_ALERT</description>
        <protected>false</protected>
        <recipients>
            <recipient>Mailshop_Team</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Notify_Art_Out_Changed</template>
    </alerts>
    <alerts>
        <fullName>PT_Cancelled_PT_Record</fullName>
        <ccEmails>xmpiesupport@eab.com,kbrenneman@eab.com</ccEmails>
        <description>PT: Cancelled PT Record</description>
        <protected>false</protected>
        <recipients>
            <recipient>Mailshop_Team</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Print_Production_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Production_Tracking_is_Cancelled</template>
    </alerts>
    <alerts>
        <fullName>PT_Email_Bus_Ops_Team_Live_Proof_Status</fullName>
        <ccEmails>xmpie@eab.com</ccEmails>
        <description>PT: Email Bus Ops Team Live Proof Status</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Record_Set_to_Live_Proof_Status</template>
    </alerts>
    <alerts>
        <fullName>PT_Email_Related_Users_that_PT_in_Proof_Status</fullName>
        <ccEmails>xmpiesupport@eab.com</ccEmails>
        <description>PT: Email Related Users that PT in Proof Status</description>
        <protected>false</protected>
        <recipients>
            <recipient>Print_Team</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Print_Production_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Proof_ready_for_Approval</template>
    </alerts>
    <alerts>
        <fullName>PT_Email_XMPie_when_Approved_by_Partner_Status</fullName>
        <ccEmails>xmpie@eab.com</ccEmails>
        <ccEmails>xmpiesupport@eab.com</ccEmails>
        <description>PT: Email XMPie when Approved by Partner Status</description>
        <protected>false</protected>
        <recipients>
            <recipient>Art_Prep_Team</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Print_Production_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Approved_by_Partner_XMPie_Alert</template>
    </alerts>
    <alerts>
        <fullName>PT_Live_Proof_Approved_Alert</fullName>
        <ccEmails>enrollmentservicesmailservices@eab.com</ccEmails>
        <description>PT: Live Proof Approved Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Live_Proof_Approved</template>
    </alerts>
    <alerts>
        <fullName>PT_Live_Proof_Pending_Approval_Notification_2Hr_Reminder</fullName>
        <description>zzzPT Live Proof Pending Approval Notification 2Hr Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>JT_PM_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PTLive_Proof_Pending_Approval_For_2Hr</template>
    </alerts>
    <alerts>
        <fullName>PT_Live_Proof_Pending_Approval_Notification_3Hr_Reminder</fullName>
        <description>PT Live Proof Pending Approval Notification 3Hr Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PTLive_Proof_Pending_Approval_For_3Hr</template>
    </alerts>
    <alerts>
        <fullName>PT_Live_Proof_Rejected_Alert</fullName>
        <ccEmails>enrollmentservicesmailservices@eab.com</ccEmails>
        <description>PT: Live Proof Rejected Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Live_Proof_Rejected</template>
    </alerts>
    <alerts>
        <fullName>PT_Mail_Date_Confirmation_3Hr_Reminder</fullName>
        <ccEmails>xmpie@eab.com</ccEmails>
        <description>PT Mail Date Confirmation 3Hr Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PTMail_Date_Pending_Confirmation_3hrs</template>
    </alerts>
    <alerts>
        <fullName>PT_Notify_PM_that_Vendor_Mailing_List_Received_EA</fullName>
        <ccEmails>EnrollmentServicesMailServices@eab.com</ccEmails>
        <description>PT: Notify PM that Vendor Mailing List # Received EA</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Mailing_List_Received_from_Vendor</template>
    </alerts>
    <alerts>
        <fullName>PT_Production_Tracking_Package_has_been_mailed</fullName>
        <ccEmails>EnrollmentServicesProductionManagers@eab.com</ccEmails>
        <description>PT: Production Tracking Package has been mailed</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Production_Tracking_Package_has_mailed</template>
    </alerts>
    <alerts>
        <fullName>PT_Ready_for_Proof_20_Days_EA</fullName>
        <ccEmails>xmpiesupport@eab.com</ccEmails>
        <description>PT: Ready for Proof &lt;= 20 Days EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>kbrey@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Print_Production_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Ready_for_Proof_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>PT_Ready_for_Proof_21_Days_EA</fullName>
        <ccEmails>xmpiesupport@eab.com</ccEmails>
        <description>PT: Ready for Proof &gt;= 21 Days EA</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Print_Production_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Ready_for_Proof_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>PT_Status_Detail_Error_Alert</fullName>
        <ccEmails>xmpie@eab.com</ccEmails>
        <description>PT: Status Detail Error Alert</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/PT_Status_Detail_Error_Email</template>
    </alerts>
    <alerts>
        <fullName>PT_Vendor_Mail_Date_Alert</fullName>
        <ccEmails>EnrollmentServicesProductionManagers@eab.com</ccEmails>
        <description>PT: Vendor Mail Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>JT_Project_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/Vendor_Mail_Date_Changed</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_Live_Proof_Pending_Approval_DateTime</fullName>
        <description>Created for CR-20200616-14191.</description>
        <field>Live_Proof_Pending_Approval_DateTime__c</field>
        <formula>NOW()</formula>
        <name>FU_Live Proof Pending Approval DateTime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Status_Detail_Live_Proof_Approved</fullName>
        <field>Status_Detail__c</field>
        <literalValue>Live Proof Approved</literalValue>
        <name>FU: Status Detail = Live Proof Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Status_Detail_Submitted</fullName>
        <field>Status_Detail__c</field>
        <literalValue>Submitted</literalValue>
        <name>FU: Status Detail = Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increment_Version_Number</fullName>
        <field>Version_Number__c</field>
        <formula>IF(ISBLANK(Version_Number__c), 1, Version_Number__c + 1)</formula>
        <name>Increment Version Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Live_Proof_Approve_Status_Approved</fullName>
        <field>Live_Proof_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>PT Live Proof Approve Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Live_Proof_Approve_Status_Blank</fullName>
        <field>Live_Proof_Approval_Status__c</field>
        <name>PT Live Proof Approve Status Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Live_Proof_Approve_Status_Rejected</fullName>
        <field>Live_Proof_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>PT Live Proof Approve Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Proof_Approve_Status_Approved</fullName>
        <field>Proof_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>PT Proof Approve Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Proof_Approve_Status_Rejected</fullName>
        <field>Proof_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>PT Proof Approve Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Record_Status_set_to_Approved</fullName>
        <field>Status_Detail__c</field>
        <literalValue>Approved</literalValue>
        <name>PT Record Status set to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Status_Detail_set_to_Blank</fullName>
        <field>Status_Detail__c</field>
        <name>PT Status Detail set to Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Vendor_Mail_Date_Prior_Value</fullName>
        <description>Populates the Vendor Mail Date (Prior Value) when Vendor Mail Date is updated.</description>
        <field>Vendor_Mail_Date_Prior_Value__c</field>
        <formula>PRIORVALUE( Vendor_Mail_Date__c )</formula>
        <name>PT Vendor Mail Date (Prior Value)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_back_to_Approved_by_Partner</fullName>
        <field>Status__c</field>
        <literalValue>Approved by Partner</literalValue>
        <name>Set Record back to Approved by Partner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Detail_to_Approved</fullName>
        <field>Status_Detail__c</field>
        <name>Set Status Detail to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_back_to_Proof</fullName>
        <field>Status__c</field>
        <literalValue>Approved by Partner</literalValue>
        <name>Set Status back to Proof</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Ready_for_Print</fullName>
        <field>Status__c</field>
        <literalValue>Ready for Print</literalValue>
        <name>Set Status to Ready for Print</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_for_Live_Proof_Approval</fullName>
        <field>Status_Detail__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Submitted for Live Proof Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IsLocked_for_Proof_on_Rejection</fullName>
        <field>is_Locked__c</field>
        <literalValue>0</literalValue>
        <name>Update IsLocked for Proof on Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IsLocked_to_False_for_Live_Proof</fullName>
        <field>is_Locked__c</field>
        <literalValue>0</literalValue>
        <name>Update IsLocked to False for Live Proof</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IsLocked_to_False_for_Proof</fullName>
        <field>is_Locked__c</field>
        <literalValue>0</literalValue>
        <name>Update IsLocked to False for Proof</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IsLocked_to_False_on_Rejection</fullName>
        <field>is_Locked__c</field>
        <literalValue>0</literalValue>
        <name>Update IsLocked to False on Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IsLocked_to_True_for_Live_Proof</fullName>
        <field>is_Locked__c</field>
        <literalValue>1</literalValue>
        <name>Update IsLocked to True for Live Proof</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IsLocked_to_True_for_Proof</fullName>
        <field>is_Locked__c</field>
        <literalValue>1</literalValue>
        <name>Update IsLocked to True for Proof</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PT%3A Drop 1 Target Date - Not Proof Status</fullName>
        <active>true</active>
        <formula>AND(   OR(     TEXT(Status__c) == &quot;Approved by Partner&quot;,     TEXT(Status__c) == &quot;Planned&quot;   ),   ISPICKVAL(Job_Ticket__r.Vendor_Type__c, &quot;Digital&quot;),   NOT(ISBLANK(Planned_Mail_Date__c)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PT_Ready_for_Proof_21_Days_EA</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Production_Tracking__c.Planned_Mail_Date__c</offsetFromField>
            <timeLength>-21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>PT_Ready_for_Proof_20_Days_EA</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Production_Tracking__c.Planned_Mail_Date__c</offsetFromField>
            <timeLength>-20</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PT%3A Increase Version Number</fullName>
        <actions>
            <name>Increment_Version_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Increase Version Number by+1 when PT Status or StatusDetail changes</description>
        <formula>AND(   OR(     ISCHANGED(Status__c),     ISCHANGED(Status_Detail__c)   )/*,   OR(     AND(       ISPICKVAL(Status__c, &apos;Proof&apos;),       ISPICKVAL(Status_Detail__c, &apos;Submitted&apos;)     ),     AND(       ISPICKVAL(Status__c, &apos;Live Proof&apos;),       ISPICKVAL(Status_Detail__c, &apos;Submitted&apos;)     ),     AND(       ISPICKVAL(Status__c, &apos;Live Proof&apos;),       ISPICKVAL(Status_Detail__c, &apos;Approved&apos;)     ),     AND(       ISPICKVAL(Status__c, &apos;Ready for Print&apos;),       ISPICKVAL(Status_Detail__c, &apos;Live Proof Approved&apos;)     )   )*/ )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PT%3A Live Proof Approved</fullName>
        <actions>
            <name>FU_Status_Detail_Live_Proof_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Status_to_Ready_for_Print</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Production Tracking Status = Live Proof &amp; Status Detail=Approved, automatically update the Status=Ready for Print if Proof Generation=External</description>
        <formula>AND(   ISPICKVAL(Status__c, &quot;Live Proof&quot;),   ISCHANGED(Status_Detail__c),   ISPICKVAL(Status_Detail__c, &quot;Live Proof Approved&quot;),   ISPICKVAL(Proof_Generation__c, &quot;External&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PT%3A Mailing List %23 Received from Vendor</fullName>
        <actions>
            <name>PT_Notify_PM_that_Vendor_Mailing_List_Received_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Initial_Count__c) || ISCHANGED(Imported_Students__c) || ISCHANGED(Imported_Seeds__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PT%3A Production Tracking Package is set to mailed</fullName>
        <actions>
            <name>PT_Production_Tracking_Package_has_been_mailed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Production_Tracking__c.Status__c</field>
            <operation>equals</operation>
            <value>Mailed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PT%3A Status %3D Live Proof</fullName>
        <actions>
            <name>EA_PT_Record_Set_to_Live_Proof_Status</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_Status_Detail_Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Production Tracking Status = Live Proof, automatically update the Status Detail = Submitted</description>
        <formula>AND(   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Live Proof&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PT%3A Status %3D Proof</fullName>
        <actions>
            <name>FU_Status_Detail_Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Production Tracking Status = Proof, automatically update the Status Detail = Submitted</description>
        <formula>AND(   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Proof&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PT%3A Status %3D Ready for Print</fullName>
        <actions>
            <name>FU_Status_Detail_Live_Proof_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Production Tracking Status = Ready for Print, automatically update the Status Detail = Live Proof Approved</description>
        <formula>AND(   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Ready for Print&quot;),   NOT( RecordType.DeveloperName == &quot;Print&quot; ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PT%3A Vendor Mail Date %28Prior Value%29</fullName>
        <actions>
            <name>PT_Vendor_Mail_Date_Prior_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Vendor Mail Date (Prior Value) when Vendor Mail Date is updated.</description>
        <formula>AND(   ISCHANGED( Vendor_Mail_Date__c ),   NOT(ISBLANK( Vendor_Mail_Date__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WR_PT%3A Cancelled PT Record</fullName>
        <actions>
            <name>PT_Cancelled_PT_Record</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Production_Tracking__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>Created via - CR-20210825-15380</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
