<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Cappex_Management_When_Opportunity_Lost</fullName>
        <description>Alert Cappex Management When Opportunity Lost</description>
        <protected>false</protected>
        <recipients>
            <recipient>aolson@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cfait@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jvollmer@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tsingh@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Lost_Opportunity_Notification</template>
    </alerts>
    <alerts>
        <fullName>Alert_Cappex_Management_When_Opportunity_Won</fullName>
        <description>Alert Cappex Management When Opportunity Won</description>
        <protected>false</protected>
        <recipients>
            <recipient>Audience_PSMs</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Won_Opportunity_Notification</template>
    </alerts>
    <alerts>
        <fullName>CT_Need_More_Information_EA</fullName>
        <description>CT: Need More Information EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Chairman_s_Team/CT_Need_More_Information</template>
    </alerts>
    <alerts>
        <fullName>Cappex_Opp_Stage_Change</fullName>
        <description>Cappex Opp Stage Change</description>
        <protected>false</protected>
        <recipients>
            <recipient>jcampbell@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tsingh@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cappex_Email_Templates/Cappex_Opp_Stage_Change</template>
    </alerts>
    <alerts>
        <fullName>Chairman_s_Team_Assignment_Email</fullName>
        <description>Chairman&apos;s Team Assignment Email</description>
        <protected>false</protected>
        <recipients>
            <field>CT_Assignment_s_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>CT_Assignment__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>CT_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Chairman_s_Team/New_Chairman_s_Team_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Chairman_s_Team_Reneg_Email</fullName>
        <description>Chairman&apos;s Team Reneg Email</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Strat_Ops_AM_Associate_CT_Tagging</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>cvogel@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>CT_Assignment__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>CT_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Chairman_s_Team/New_Chairman_s_Team_Reneg_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Tech_Call_Marketer_Survey</fullName>
        <description>Tech Call Marketer Survey</description>
        <protected>false</protected>
        <recipients>
            <recipient>Marketers_Survey_Members</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Marketer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketer_Survey/Tech_Call_Marketer_Survey</template>
    </alerts>
    <fieldUpdates>
        <fullName>CT_Date_Passed_Populated_FU</fullName>
        <field>CT_Date_Passed__c</field>
        <formula>TODAY()</formula>
        <name>CT: Date Passed Populated FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_MYOO_Pool_for_AM_Group</fullName>
        <field>Current_Half_MYOO_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Half MYOO Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_MYOO_Pool_for_owner</fullName>
        <field>Current_Half_MYOO_Pool_for_owner__c</field>
        <formula>0</formula>
        <name>Current Half MYOO Pool for owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_New_LOA_Pool_for_AM_Group</fullName>
        <field>Current_Half_New_LOA_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Half New LOA Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_New_LOA_Pool_for_owner</fullName>
        <field>Current_Half_New_LOA_Pool_for_owner__c</field>
        <formula>0</formula>
        <name>Current Half New LOA Pool for owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_Total_Pool_for_AM_Group</fullName>
        <field>Current_Half_Total_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Half Total Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_Total_Pool_for_owner</fullName>
        <field>Current_Half_Total_Pool_for_owner__c</field>
        <formula>0</formula>
        <name>Current Half Total Pool for owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Year_Total_Pool_for_AM_Group</fullName>
        <field>Current_Year_Total_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Year Total Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Year_Total_Pool_for_Owner</fullName>
        <field>Current_Year_Total_Pool_for_Owner__c</field>
        <formula>0</formula>
        <name>Current Year Total Pool for Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Date_First_Moved_To_Phase_2</fullName>
        <description>Created for CR-20170221-10708.</description>
        <field>Date_First_Moved_to_Phase_2__c</field>
        <formula>Today()</formula>
        <name>FU_Date_First_Moved_To_Phase_2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Date_First_Moved_To_Phase_3</fullName>
        <description>Created for CR-20170221-10708.</description>
        <field>Date_First_Moved_to_Phase_3__c</field>
        <formula>Today()</formula>
        <name>FU_Date_First_Moved_To_Phase_3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Roll_Back_Date_First_Moved_To_Phase_3</fullName>
        <description>Created for CR-20170221-10708.</description>
        <field>Date_First_Moved_to_Phase_3__c</field>
        <name>FU_Roll_Back_Date_First_Moved_To_Phase_3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposal_Value_Update_AM_Pending_Opps</fullName>
        <field>Amount</field>
        <formula>Previous_Year_Negotiated_Credit__c</formula>
        <name>Proposal Value Update AM Pending Opps</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Alert Cappex Management When Opportunity Lost</fullName>
        <actions>
            <name>Alert_Cappex_Management_When_Opportunity_Lost</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Legacy Acquisition</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Greenlight</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Source_Business__c</field>
            <operation>equals</operation>
            <value>Cappex - Candidates,Cappex,Intersect</value>
        </criteriaItems>
        <description>Created for CR-20201105-14667</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Cappex Management When Opportunity Won</fullName>
        <actions>
            <name>Alert_Cappex_Management_When_Opportunity_Won</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Legacy Acquisition</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Greenlight</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Source_Business__c</field>
            <operation>equals</operation>
            <value>Cappex - Candidates,Cappex,Intersect</value>
        </criteriaItems>
        <description>Created for CR-20201105-14667</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CT%3A Date Passed Populated</fullName>
        <actions>
            <name>CT_Date_Passed_Populated_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CT_Pass_Status__c</field>
            <operation>equals</operation>
            <value>Ready for Assignment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>Populate CT: Date Passed with Today&apos;s date when CT: Pass Status = &quot;Ready for Assignment&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CT%3A Need More Information</fullName>
        <actions>
            <name>CT_Need_More_Information_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( 	  		NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Opportunity&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(CT_Pass_Status__c, &apos;Need more info&apos;), 		NOT(RecordType.DeveloperName = &apos;Royall&apos;)     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Chairman%27s Team Assignment</fullName>
        <actions>
            <name>Chairman_s_Team_Assignment_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( 	  		NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Opportunity&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(CT_Pass_Status__c, &apos;Assigned&apos;), 		NOT(RecordType.DeveloperName = &apos;Royall&apos;),   ISBLANK(TEXT(CT_Reneg_Attempt__c)) 		  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Chairman%27s Team Reneg Attempt</fullName>
        <actions>
            <name>Chairman_s_Team_Reneg_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( 	  		NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Opportunity&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(CT_Pass_Status__c, &apos;Assigned&apos;), 		NOT(RecordType.DeveloperName = &apos;Royall&apos;),   ISPICKVAL(CT_Reneg_Attempt__c, &apos;Yes&apos;) 		  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Stage Change</fullName>
        <actions>
            <name>Cappex_Opp_Stage_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT( ISBLANK( RecordTypeId ) ), RecordType.DeveloperName = &apos;Legacy_Cappex&apos;,ISCHANGED(StageName), OR(TEXT(Source_Business__c) = &apos;Intersect&apos;, TEXT(Source_Business__c) = &apos;Cappex - Candidates&apos;, TEXT(Source_Business__c) = &apos;Cappex - Non-Candidates&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Value Update AM Pending Opps</fullName>
        <actions>
            <name>Proposal_Value_Update_AM_Pending_Opps</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>PT Contract Maintenance,PT Contract Renewal,RI AM First Year Opp,RI AM Standard Opp</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Pending- Renewal Call Comp &amp; Evaluating,Pending- Renewal Call Comp &amp; Contracting,Pending- Renewal Call Not Yet Occured,Pending</value>
        </criteriaItems>
        <description>Sets proposal value equal to value of prev. neg. credit if prop value = 0, is an AM opp, and stage contains pending.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ValidatPoolFields</fullName>
        <actions>
            <name>Current_Half_MYOO_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_MYOO_Pool_for_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_New_LOA_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_New_LOA_Pool_for_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_Total_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_Total_Pool_for_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Year_Total_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Year_Total_Pool_for_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>When the Opportunity field &apos;Closed&apos; = True,  Change the value of these fields to &apos;0&apos;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Date_First_Moved_To_Phase_2</fullName>
        <actions>
            <name>FU_Date_First_Moved_To_Phase_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20170221-10708.</description>
        <formula>AND( 	ISPICKVAL(Pipeline_Stage__c,&apos;2 - Member Need Confirmed&apos;), 	ISBLANK(Date_First_Moved_to_Phase_2__c)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Date_First_Moved_To_Phase_3</fullName>
        <actions>
            <name>FU_Date_First_Moved_To_Phase_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20170221-10708.</description>
        <formula>AND( 	ISPICKVAL(Pipeline_Stage__c,&apos;3 - Member Agrees To A Commercial Pitch&apos;), 	ISBLANK(Date_First_Moved_to_Phase_3__c)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Roll_Back_Date_First_Moved_To_Phase_3</fullName>
        <actions>
            <name>FU_Roll_Back_Date_First_Moved_To_Phase_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20170221-10708.</description>
        <formula>AND (      ISPICKVAL(PRIORVALUE(Pipeline_Stage__c), &apos;3 - Member Agrees To A Commercial Pitch&apos;),     ISPICKVAL(Pipeline_Stage__c,&apos;2 - Member Need Confirmed&apos;),     NOT(ISBLANK(Date_First_Moved_to_Phase_3__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Chairmans_Team_Pipeline_Overlap_Notification</fullName>
        <assignedTo>PT - Chairman&apos;s Team</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>There is another Opportunity that is &apos;active&apos; with a stage of &apos;fast track&apos; or &apos;initial visit scheduled&apos; with the same Institution.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Chairman&apos;s Team: Pipeline Overlap Notification</subject>
    </tasks>
    <tasks>
        <fullName>Cheif_of_Staff_Pipeline_Overlap_Notification</fullName>
        <assignedTo>PT - Chief of Staff</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>There is another Opportunity that is &apos;active&apos; with a stage of &apos;fast track&apos; or &apos;initial visit scheduled&apos; with the same Institution.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Cheif of Staff: Pipeline Overlap Notification</subject>
    </tasks>
    <tasks>
        <fullName>Closing_Call_Needs_to_Occur</fullName>
        <assignedToType>owner</assignedToType>
        <description>Its been 40 days since you&apos;ve closed your opportunity.  Please schedule a Closing Call.</description>
        <dueDateOffset>5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Closing Call Needs to Occur</subject>
    </tasks>
    <tasks>
        <fullName>Dormant_Rejected_Opportunity_Notification</fullName>
        <assignedTo>sfadmin@eab.com.eab</assignedTo>
        <assignedToType>user</assignedToType>
        <description>The opportunity has been in the &quot;Sent to Finance - Rejected Opp&quot; for more than 2 days.  Please take the necessary action to move this opportunity out of this stage.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Dormant Rejected Opportunity Notification</subject>
    </tasks>
    <tasks>
        <fullName>Leadership_Team_Pipeline_Overlap_Notification</fullName>
        <assignedTo>PT - Leadership Team</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>There is another Opportunity that is &apos;active&apos; with a stage of &apos;fast track&apos; or &apos;initial visit scheduled&apos; with the same Institution.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Leadership Team: Pipeline Overlap Notification</subject>
    </tasks>
    <tasks>
        <fullName>Reapproach_date_within_30_days</fullName>
        <assignedTo>PT - Marketing Associate</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>This is a reminder that the re-approach date on one of your opportunities is in 30 days or less.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.Re_approach_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reapproach date within 30 days</subject>
    </tasks>
    <tasks>
        <fullName>core_Reapproach_date_within_30_days</fullName>
        <assignedTo>RI - Marketing Associate</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>This is a reminder that the re-approach date on one of your opportunities is in 30 days or less.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.Re_approach_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reapproach date within 30 days</subject>
    </tasks>
</Workflow>
