<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Advisory_com_Password_Reset_Email</fullName>
        <description>Advisory.com Password Reset Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>eabhelp@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/A_com_Password_Reset</template>
    </alerts>
    <alerts>
        <fullName>Contact_Email_Update</fullName>
        <description>Contact Email Update</description>
        <protected>false</protected>
        <recipients>
            <recipient>create-salesforce-3@tickd.it.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Royall_Email_Templates/Contact_Email_Update</template>
    </alerts>
    <alerts>
        <fullName>Contact_Institution_Update</fullName>
        <description>Contact Institution Update</description>
        <protected>false</protected>
        <recipients>
            <recipient>create-salesforce-3@tickd.it.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Royall_Email_Templates/Contact_Institution_Update</template>
    </alerts>
    <fieldUpdates>
        <fullName>Contact_Change_Record_Type_for_a_com</fullName>
        <field>RecordTypeId</field>
        <lookupValue>External_Advisory_com_User</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Contact: Change Record Type for a.com</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Contact Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Num_Undeliverable_Mailings_Null</fullName>
        <description>Update the # Undeliverable Mailings field on the Contact object to null.</description>
        <field>Num_Undeliverable_Mailings__c</field>
        <name>FU: Num Undeliverable Mailings Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Picklist</fullName>
        <field>Record_Type__c</field>
        <literalValue>US Provider</literalValue>
        <name>Record Type Picklist: US Provider</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Picklist_Standard</fullName>
        <field>Record_Type__c</field>
        <literalValue>HCIC</literalValue>
        <name>Record Type Picklist Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Converted_from_Lead</fullName>
        <description>This field update is used to mark Converted to Lead as False after it has been converted from a Contact to Vet. This runs on a one hour time dependent delay.</description>
        <field>Converted_From_Lead__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Converted from Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Member_Verified_Date_to_Today</fullName>
        <field>Member_Verified_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Member Verified Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Contact Email Update</fullName>
        <actions>
            <name>Contact_Email_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule is used to send a notification when a Contact&apos;s Email has changed</description>
        <formula>AND ( 	    NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Contact&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 	 ISCHANGED(Email), 		Royall_com_Site_Profile_Count__c &gt; 0		 	 	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact Historical Linker</fullName>
        <actions>
            <name>Contact_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;), OR( Historical_Linker__c=&quot;&quot; , Historical_Linker__c &lt;&gt; Counter_ID__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact Institution Update</fullName>
        <actions>
            <name>Contact_Institution_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>his rule is used to send a notification when a Contact&apos;s Institution has changed</description>
        <formula>AND ( 	    NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Contact&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 	 ISCHANGED(AccountId), 		Royall_com_Site_Profile_Count__c &gt; 0 	 	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%3A Change Record Type for a%2Ecom</fullName>
        <actions>
            <name>Contact_Change_Record_Type_for_a_com</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Create_Advisory_com_User_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>External</value>
        </criteriaItems>
        <description>when Contact has an A.com user status, change record type to External - Advisory.com user.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Function%3A HCICs</fullName>
        <actions>
            <name>Record_Type_Picklist_Standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>International HCIC,US HCIC</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Function%3A US Provider</fullName>
        <actions>
            <name>Record_Type_Picklist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>US Provider</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Uncheck Converted from Lead</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Converted_From_Lead__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow rule is used to mark Converted to Lead as False after it has been converted from a Contact to Vet.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Uncheck_Converted_from_Lead</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>WF_Update_Num_Undeliverable_Mailings</fullName>
        <actions>
            <name>FU_Num_Undeliverable_Mailings_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If any of the Primary Address fields on the Contact are updated when # Undeliverable Mailings is greater than 0, set the value back to null.</description>
        <formula>OR(      ISCHANGED( Primary_Address_Line_1__c ) ,      ISCHANGED( Primary_Address_Line_2__c ) ,      ISCHANGED( Primary_Address_Line_3__c ) ,      ISCHANGED( Primary_City__c ) ,      ISCHANGED( Primary_Country__c ) ,      ISCHANGED( Primary_Postal_Code__c ) ,      ISCHANGED( Primary_State_Province__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
