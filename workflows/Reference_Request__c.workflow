<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Additional_Recommendations_Needed_Notification</fullName>
        <description>Additional Recommendations Needed Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Recommendations_Need_Additional_Reference_Recommendations</template>
    </alerts>
    <alerts>
        <fullName>New_Reference_Request_Notification</fullName>
        <description>New Reference Request Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/New_Reference_Request_Notification</template>
    </alerts>
    <alerts>
        <fullName>Reference_Recommendation_Submitted_Notification</fullName>
        <description>Reference Recommendation Submitted Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Marketer__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Recommendation_Template</template>
    </alerts>
    <alerts>
        <fullName>Reference_Recommendations_Selected_Notification</fullName>
        <description>Reference Recommendations Selected Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Recommendations_Selected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Date_Recommendations_Provided</fullName>
        <field>Date_Recommendations_Provided__c</field>
        <formula>NOW()</formula>
        <name>Update Date Recommendations Provided</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_References_Selected</fullName>
        <field>Date_References_Selected__c</field>
        <formula>NOW()</formula>
        <name>Update Date References Selected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>New Reference Request Notification</fullName>
        <actions>
            <name>New_Reference_Request_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Reference_Request__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),				 		ISPICKVAL(Request_Status__c, &apos;New&apos;)      )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Date Recommendations Provided</fullName>
        <actions>
            <name>Reference_Recommendation_Submitted_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Date_Recommendations_Provided</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Auto-updates Date Recommendations Provided and Recommendations Provided By when Request Status is set to ‘Recommended’.</description>
        <formula>AND(    				NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Reference_Request__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),		 		ISCHANGED( Request_Status__c ),    		ISPICKVAL( Request_Status__c , &quot;Recommended&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Date References Selected</fullName>
        <actions>
            <name>Reference_Recommendations_Selected_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Date_References_Selected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>References_Selected</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Auto-updates Date References Selected when Request Status is set to ‘Selected’.</description>
        <formula>AND(  		NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Reference_Request__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),				  	ISCHANGED( Request_Status__c ),   ISPICKVAL( Request_Status__c , &quot;Selected&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Send_Reference_Needed_Details_To_Requester</fullName>
        <actions>
            <name>Additional_Recommendations_Needed_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a user indicates &apos;Need Additional Reference Recommendations&apos;, an email should be sent back to the Reference Lead.  This will let them know they need to provide additional choices. Created for CR-20160204-9586</description>
        <formula>AND(  NOT(  AND(  $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,  OR(  CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Reference_Request__c&quot;),  CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)  )  )  ),	  ISPICKVAL(Selection_Status__c , &quot;Need Additional Reference Recommendations&quot;),  ISPICKVAL( Request_Status__c , &quot;Search&quot;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>References_Selected</fullName>
        <assignedToType>owner</assignedToType>
        <description>[auto-generated task]</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>References Selected</subject>
    </tasks>
</Workflow>
