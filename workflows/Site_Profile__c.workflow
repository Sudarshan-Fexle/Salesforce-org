<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Site_Profile_Adv_com_Email_Changed_Notification_Email_Alert</fullName>
        <description>Site Profile: (Adv.com) Email Changed Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Username__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>eabhelp@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/Site_Profile_Email_Change</template>
    </alerts>
    <alerts>
        <fullName>Site_Profile_Adv_com_New_User_Email_Alert</fullName>
        <description>Site Profile: (Adv.com) New User Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Username__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>eabhelp@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/Site_Profile_Welcome_Email</template>
    </alerts>
    <alerts>
        <fullName>Site_Profile_Adv_com_Password_Reset_Email_Alert</fullName>
        <description>Site Profile: (Adv.com) Password Reset Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Username__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>eabhelp@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/Adv_com_Password_Reset_Email</template>
    </alerts>
    <alerts>
        <fullName>Site_Profile_EAB_com_Email_Changed_Notification_Email_Alert</fullName>
        <description>Site Profile: (EAB.com) Email Changed Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Username__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>eabhelp@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/Site_Profile_Email_Change</template>
    </alerts>
    <alerts>
        <fullName>Site_Profile_EAB_com_New_User_Email_Alert</fullName>
        <description>Site Profile: (EAB.com) New User Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Username__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>eabhelp@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/Site_Profile_Welcome_Email</template>
    </alerts>
    <alerts>
        <fullName>Site_Profile_EAB_com_Password_Reset_Email_Alert</fullName>
        <description>Site Profile: (EAB.com) Password Reset Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Username__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>eabhelp@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/Site_Profile_Password_Reset</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_Null_Send_Password_Notification</fullName>
        <field>Send_Password_Notification__c</field>
        <name>FU Null Send Password Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Password_Null</fullName>
        <field>Password__c</field>
        <name>FU_Password_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Site_Profile_Record_Type_Active</fullName>
        <description>Updates the site profile record type to Active.</description>
        <field>RecordTypeId</field>
        <lookupValue>Active</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FU Site Profile Record Type Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Site_Profile_Record_Type_Inactive</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Inactive</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FU Site Profile Record Type Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Site Profile%3A Send EAB Email Change Notification</fullName>
        <actions>
            <name>Site_Profile_EAB_com_Email_Changed_Notification_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_Null_Send_Password_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Password_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When an existing Site User has their email address changed, send them a verification email.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Site_Profile__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 			ISPICKVAL(Send_Password_Notification__c, &apos;Email Change&apos;), 			ISPICKVAL(Type__c, &apos;EAB.com&apos;)	 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Profile%3A Send EAB Password Reset Email</fullName>
        <actions>
            <name>Site_Profile_EAB_com_Password_Reset_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_Null_Send_Password_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Password_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send password reset email when a Site Profile User resets their Password.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Site_Profile__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 			ISPICKVAL(Send_Password_Notification__c, &apos;Password Reset&apos;), 			ISPICKVAL(Type__c, &apos;EAB.com&apos;)	 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Profile%3A Send Email Change Notification</fullName>
        <actions>
            <name>Site_Profile_Adv_com_Email_Changed_Notification_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_Null_Send_Password_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Password_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When an existing Site User has their email address changed, send them a verification email.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Site_Profile__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 			ISPICKVAL(Send_Password_Notification__c, &apos;Email Change&apos;), 			ISPICKVAL(Type__c, &apos;Advisory.com&apos;)	 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Profile%3A Send Password Reset Email</fullName>
        <actions>
            <name>Site_Profile_Adv_com_Password_Reset_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_Null_Send_Password_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Password_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send password reset email when a Site Profile User resets their Password.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Site_Profile__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 			ISPICKVAL(Send_Password_Notification__c, &apos;Password Reset&apos;), 			ISPICKVAL(Type__c, &apos;Advisory.com&apos;)	 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Profile%3A Send new EAB User Email</fullName>
        <actions>
            <name>Site_Profile_EAB_com_New_User_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_Null_Send_Password_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Password_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send the welcome email when a new Site Profile has been created.</description>
        <formula>AND(      		NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Site_Profile__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 				 		ISPICKVAL(Send_Password_Notification__c , &apos;New User&apos;),      		ISPICKVAL( Type__c , &apos;EAB.com&apos;),      		OR(        						AND (          										NOT(ISNULL( Contact__c )),          										NOT(ISNULL( Contact__r.AccountId)),          										NOT( CONTAINS($Label.AdvisoryGuestAccountID, Contact__r.AccountId))                 	     ),        		    Trigger_Guest_Welcome_Email__c      		 )    )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Profile%3A Send new User Email</fullName>
        <actions>
            <name>Site_Profile_Adv_com_New_User_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_Null_Send_Password_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Password_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send the welcome email when a new Site Profile has been created.</description>
        <formula>AND(    				 				NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Site_Profile__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 				 				ISPICKVAL(Send_Password_Notification__c  , &apos;New User&apos;),   ISPICKVAL( Type__c , &apos;Advisory.com&apos;),   OR(      AND(         NOT(ISNULL( Contact__c )),       NOT(ISNULL( Contact__r.AccountId)),       Contact__r.Account.Name  &lt;&gt; &apos;Advisory Guest - Washington - DC&apos;      ),     Trigger_Guest_Welcome_Email__c   )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF Record Type Update%3A Site Profile Active</fullName>
        <actions>
            <name>FU_Site_Profile_Record_Type_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Profile__c.Status__c</field>
            <operation>equals</operation>
            <value>Active,In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Profile__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>MyRoyall</value>
        </criteriaItems>
        <description>Updates the site profile&apos;s Record Type to Inactive when status is updated to Active or In Progress.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF Record Type Update%3A Site Profile Inactive</fullName>
        <actions>
            <name>FU_Site_Profile_Record_Type_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Profile__c.Status__c</field>
            <operation>equals</operation>
            <value>Inactive,Hard Bounce</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Profile__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>MyRoyall</value>
        </criteriaItems>
        <description>Updates the site profile&apos;s Record Type to Inactive when status is updated to inactive or hard bounce.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
