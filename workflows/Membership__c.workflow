<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Member_Notification_to_New_Member_On_Boarding_Team</fullName>
        <description>New Member Notification to New Member On Boarding Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>RI - Account Exec</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Chairman&apos;s Team</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Chief of Staff</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Dedicated Advisor</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Executive Advisor</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Growth Account Director</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Leadership Team</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Leadership Team/Cabinet</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Marketer</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Marketing Associate</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Marketing Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Operations</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Product Marketing Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Relationship Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Activity_with_New_Member</template>
    </alerts>
    <fieldUpdates>
        <fullName>Meeting_Registration_Status_Secondary</fullName>
        <field>Meeting_Updated_Date_Secondary__c</field>
        <formula>TODAY()</formula>
        <name>Meeting Registration Status, Secondary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Reason_for_No_QA_Call</fullName>
        <field>Reason_for_No_QA_Call__c</field>
        <name>Remove Reason for No QA Call</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Meeting Registration Status Primary%2C Last Updated</fullName>
        <active>true</active>
        <formula>OR(ISCHANGED(Meeting_Status_Primary__c),  ISCHANGED(Meeting_Registration_Comments__c), NOT(ISPICKVAL(Meeting_Status_Primary__c, &apos;&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Meeting Registration Status Secondary%2C Last Updated</fullName>
        <actions>
            <name>Meeting_Registration_Status_Secondary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( 	ISCHANGED(Meeting_Status_Secondary__c), 	 ISCHANGED(Meeting_Registration_Comments__c), NOT(ISPICKVAL(Meeting_Status_Secondary__c, &apos;&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Remove Reason for No QA Call</fullName>
        <actions>
            <name>Remove_Reason_for_No_QA_Call</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Most_Recent_QA_Call_Date__c &gt; TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
