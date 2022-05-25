<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ClientStatusAlert_AtRisk</fullName>
        <description>After &apos;(R) Engagement Status&apos; for a client is deemed as an &apos;At Risk&apos; account</description>
        <protected>false</protected>
        <recipients>
            <recipient>Royall_Client_Alert_Status</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/Client_Alert_At_Risk</template>
    </alerts>
    <alerts>
        <fullName>ClientStatusAlert_Committed</fullName>
        <description>Alert client status is marked as committed.</description>
        <protected>false</protected>
        <recipients>
            <recipient>Royall_Client_Alert_Status</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/Client_Alert_Committed</template>
    </alerts>
    <alerts>
        <fullName>ClientStatusAlert_Lost</fullName>
        <description>Alert client status is marked as lost.</description>
        <protected>false</protected>
        <recipients>
            <recipient>Royall_Client_Alert_Status</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/Client_Alert_Lost</template>
    </alerts>
    <alerts>
        <fullName>ClientStatusAlert_Secured</fullName>
        <description>Alert client status is marked as secured.</description>
        <protected>false</protected>
        <recipients>
            <recipient>Royall_Client_Alert_Status</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/Client_Alert_Secured</template>
    </alerts>
    <alerts>
        <fullName>Client_Alert_New_RC</fullName>
        <ccEmails>newclientnotification@royall.com.abc</ccEmails>
        <description>Client Alert - New (RC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>Royall_New_Client</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/Client_Alert_New_RC</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_FY_End_Date</fullName>
        <description>Last day of the fiscal year, Created for CR-20170110-10605.</description>
        <field>FY_End_Date__c</field>
        <formula>DATE(VALUE(Fiscal_Year__c),6,30)</formula>
        <name>FU_FY End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_FY_Start_Date</fullName>
        <description>First day of the fiscal year, Created for CR-20170110-10605.</description>
        <field>FY_Start_Date__c</field>
        <formula>DATE((VALUE(Fiscal_Year__c)-1),7,1)</formula>
        <name>FU_FY_Start_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FY2010</fullName>
        <field>FY_Date__c</field>
        <formula>DATE(2010,06,30)</formula>
        <name>FY2010</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FY2011</fullName>
        <field>FY_Date__c</field>
        <formula>DATE(2011,06,30)</formula>
        <name>FY2011</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FY2012</fullName>
        <field>FY_Date__c</field>
        <formula>DATE (2012,06,30)</formula>
        <name>FY2012</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FY2013</fullName>
        <field>FY_Date__c</field>
        <formula>DATE(2013,06,30)</formula>
        <name>FY2013</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FY2014</fullName>
        <field>FY_Date__c</field>
        <formula>DATE(2014,06,30)</formula>
        <name>FY2014</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Client Status Alert -- At Risk</fullName>
        <actions>
            <name>ClientStatusAlert_AtRisk</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Client status is marked at risk.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Program_Package__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(Client_Status_New__c, &apos;At Risk&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Client Status Alert -- Committed</fullName>
        <actions>
            <name>ClientStatusAlert_Committed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Client status is marked as committed.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Program_Package__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(Client_Status_New__c, &apos;Committed&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Client Status Alert -- Lost</fullName>
        <actions>
            <name>ClientStatusAlert_Lost</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Client status is marked as lost.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Program_Package__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(Client_Status_New__c, &apos;Lost&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Client Status Alert -- Secured</fullName>
        <actions>
            <name>ClientStatusAlert_Secured</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Client status is marked as secured.</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Program_Package__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(Client_Status_New__c, &apos;Secured&apos;), 		NOT(CONTAINS(Name, &apos;Miscellaneous Revenue Adjustment&apos;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FY2010</fullName>
        <actions>
            <name>FY2010</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_Package__c.Fiscal_Year__c</field>
            <operation>equals</operation>
            <value>2010</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FY2011</fullName>
        <actions>
            <name>FY2011</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_Package__c.Fiscal_Year__c</field>
            <operation>equals</operation>
            <value>2011</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FY2012</fullName>
        <actions>
            <name>FY2012</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_Package__c.Fiscal_Year__c</field>
            <operation>equals</operation>
            <value>2012</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FY2013</fullName>
        <actions>
            <name>FY2013</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_Package__c.Fiscal_Year__c</field>
            <operation>equals</operation>
            <value>2013</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FY2014</fullName>
        <actions>
            <name>FY2014</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_Package__c.Fiscal_Year__c</field>
            <operation>equals</operation>
            <value>2014</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Client %28RC%29</fullName>
        <actions>
            <name>Client_Alert_New_RC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Initiates workflow when there&apos;s a new Royall &amp; Company client</description>
        <formula>AND (   NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Program_Package__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 		ISPICKVAL(Client_Status_New__c, &apos;Lost&apos;),  		R_Account_Status__c = &apos;New Client&apos;   				 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Populate_FY_First_Day %26 Last_Day</fullName>
        <actions>
            <name>FU_FY_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_FY_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (   NOT(ISNULL(Fiscal_Year__c)),  OR (   ISNEW(),     OR (    ISCHANGED(Fiscal_Year__c),    ISCHANGED(FY_Start_Date__c),    ISCHANGED(FY_End_Date__c),    ISBLANK(FY_Start_Date__c)   )  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
