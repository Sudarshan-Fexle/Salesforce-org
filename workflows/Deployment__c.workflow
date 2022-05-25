<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Compass_Business_Analyst_is_entered_on_Deployment</fullName>
        <description>Compass: Business Analyst is entered on Deployment</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Business_Analyst_is_Entered</template>
    </alerts>
    <alerts>
        <fullName>Compass_Complete_Data_In_Actual_is_entered</fullName>
        <description>Compass: Complete Data In (Actual) is entered</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Complete_Data_In_Actual_is_entered</template>
    </alerts>
    <alerts>
        <fullName>Compass_Initial_Site_Build_Complete_Actual_is_entered</fullName>
        <description>Compass: Initial Site Build Complete (Actual) is entered</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Initial_Site_Build_Complete_Actual_is_entered</template>
    </alerts>
    <alerts>
        <fullName>Compass_Internal_Validation_Complete_Actual_is_entered</fullName>
        <description>Compass: Internal Validation Complete (Actual) is entered</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Internal_Validation_Complete_Actual_is_entered</template>
    </alerts>
    <fieldUpdates>
        <fullName>Autopopulate_Deployment_Name_All_Types</fullName>
        <description>This autopopulates the Deployment Name on all Records as per CR-20120208-384</description>
        <field>Name</field>
        <formula>LEFT(Project__r.Institution__r.Name,60) + &quot; - &quot; + LEFT(Deployment_Type__r.Name,17)</formula>
        <name>Autopopulate Deployment Name - All Types</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CC_Site_Build_Complete_Expected</fullName>
        <field>C_E_ISBC__c</field>
        <formula>if(!(isblank(PT_Access_Granted_Date__c)),PT_Access_Granted_Date__c + Deployment_Type__r.Expected_CC_Complete_Data_In__c , NULL)</formula>
        <name>CC: Site Build Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Engineer_Lead</fullName>
        <description>This updates the Engineer Lead field with the user &quot;Nandini Parvathareddygari&quot; for Deployment Types: Surgical Profitability, Spend, SCI</description>
        <field>Engineer_Lead__c</field>
        <lookupValue>sfadmin@eab.com.eab</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Compass: Update Engineer Lead - 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Engineer_Lead_2</fullName>
        <description>This updates the Engineer Lead field with the user &quot;Krithika Ramachandran&quot; for Deployment Types: USC</description>
        <field>Engineer_Lead__c</field>
        <lookupValue>sfadmin@eab.com.eab</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Compass: Update Engineer Lead - 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Engineer_Lead_4</fullName>
        <description>This updates the Engineer Lead field with the user &quot;Bhavani Dandu&quot; for Deployment Types: International Spend, International Surgery, International ED</description>
        <field>Engineer_Lead__c</field>
        <lookupValue>sfadmin@eab.com.eab</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Compass: Update Engineer Lead - 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Deployment_Name</fullName>
        <field>Name</field>
        <formula>Project__r.Institution__r.Account_Formal_Name__c + &quot; - &quot; +  Program_Acronym__c + &quot; - AP/R&quot;</formula>
        <name>Populate Deployment Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Project_Planning_Expected</fullName>
        <field>Project_Planning_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c + Deployment_Type__r.Expected_Project_Planning__c , NULL)</formula>
        <name>Project Planning (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CC_Complete_Data_In_Expected</fullName>
        <field>C_E_CDI__c</field>
        <formula>if(!(isblank(PT_Access_Granted_Date__c)),PT_Access_Granted_Date__c + Deployment_Type__r.Expected_CC_Complete_Data_In__c , NULL)</formula>
        <name>Update CC: Complete Data In (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CC_Initial_Data_In_Expected</fullName>
        <field>C_E_IDI__c</field>
        <formula>if(!(isblank(PT_Access_Granted_Date__c)),PT_Access_Granted_Date__c + Deployment_Type__r.Expected_CC_Initial_Data_In__c , NULL)</formula>
        <name>Update CC: Initial Data In (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Complete_Data_In_Expected</fullName>
        <description>Updates complete data in (expected) with standard timing when &apos;use standard milestone goals&apos; is checked</description>
        <field>C_E_CDI__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Complete_Data_In__c,NULL)</formula>
        <name>Update Complete Data In Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Configuration_Complete_Expected</fullName>
        <description>Set  Configuration Complete (Expected) = Deployment Start (Actual) + Expected Configuration Complete</description>
        <field>Validation_Complete_Expected__c</field>
        <formula>C_A_DS__c + Deployment_Type__r.Expected_Integration_Config_Completed__c</formula>
        <name>Update Configuration Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Diag_Comp_Expected</fullName>
        <description>updates Data Diagnostics Complete (Expected) with standard timing when Use Standard Milestone Goals is checked</description>
        <field>C_E_DDC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Diagnostic_Sign_Off_Received__c, NULL)</formula>
        <name>Update Data Diag Comp Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Deployment_Sign_Off_Expected</fullName>
        <field>C_E_DC__c</field>
        <formula>IF(!ISBLANK(Welcome_Call_Actual__c ), Welcome_Call_Actual__c + 180 , NULL)</formula>
        <name>Update Deployment Sign Off (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Deployment_Sign_Off_Expected_1</fullName>
        <description>Update Deployment Sign Off (Expected) For APS and SSC Navigate</description>
        <field>C_E_DC__c</field>
        <formula>IF(NOT(ISBLANK(C_A_DS__c)), C_A_DS__c + 210, null)</formula>
        <name>Update Deployment Sign Off (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Deployment_Sign_Off_Expected_fi</fullName>
        <description>Created for CR-20210203-14868</description>
        <field>C_E_DC__c</field>
        <formula>IF(!ISBLANK(C_A_DS__c), C_A_DS__c + 180 , NULL)</formula>
        <name>Update Deployment Sign Off (Expected) fi</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Expected_Recurring_Update_Sign_Of</fullName>
        <field>Expected_Recurring_Update_Sign_Off2__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Recurring_Update_Sign_Off__c , NULL)</formula>
        <name>Update Expected Recurring Update Sign-Of</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Data_In_Expected</fullName>
        <description>Updates initial data in (expected) with standard timing when &apos;use standard milestone goals&apos; is checked</description>
        <field>C_E_IDI__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Initial_Data_In__c, NULL)</formula>
        <name>Update Initial Data In Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Site_Build_Complete_Exp</fullName>
        <description>updates Initial Site Build Complete (Expected) with standard timing when Use Standard Milestone Goals is checked</description>
        <field>C_E_ISBC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Site_Live__c, NULL)</formula>
        <name>Update Initial Site Build Complete Exp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Internal_Validation_Comp_Expected</fullName>
        <description>updates Initial Validation Complete (Expected) with standard timing when Use Standard Milestone Goals is checked</description>
        <field>C_E_IVC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+ Deployment_Type__r.Expected_Internal_Validation_Complete__c, NULL)</formula>
        <name>Update Internal Validation Comp Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Site_Live_Expected</fullName>
        <description>Set Site Live (Expected) = Deployment Start (Actual) + Expected Configuration Complete</description>
        <field>Site_Live_Expected__c</field>
        <formula>C_A_DS__c + Deployment_Type__r.Expected_Integration_Config_Completed__c</formula>
        <name>Update Site Live (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Site_Live_Expected_FOR_ssc</fullName>
        <field>Site_Live_Expected__c</field>
        <formula>IF(!ISBLANK(C_A_DS__c), C_A_DS__c  + 240, NULL)</formula>
        <name>Update Site Live (Expected) FOR ssc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Technical_Planning_Call_Expected</fullName>
        <field>Technical_Planning_Call_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Technical_Planning_Call__c , NULL)</formula>
        <name>Update Technical Planning Call (Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_UAT_Onsite_Expected</fullName>
        <description>CR-595</description>
        <field>UAT_Onsite_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_UAT_Onsite__c , NULL)</formula>
        <name>Update UAT Onsite (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>pdate_Expected_TechU_Planning_Complete</fullName>
        <description>updates C_E_TPC: Technical Planning Complete (Expected) to equal Actual_Deployment_Start__c + Deployment_Type__r.Expected_Technical_Kick_Off__c</description>
        <field>C_E_TPC__c</field>
        <formula>if( !(ISBLANK(C_A_DS__c) ), C_A_DS__c+ Deployment_Type__r.Expected_Technical_Planning_Complete__c,NULL)</formula>
        <name>pdate Expected TechU Planning Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Compass%3A Business Analyst is entered</fullName>
        <actions>
            <name>Compass_Business_Analyst_is_entered_on_Deployment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This sends an email to the BA when the Business Analyst is assigned on Compass Deployment record types.</description>
        <formula>AND (      NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Deployment__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 					OR ( 					    RecordType.DeveloperName = &apos;USC_Deployment&apos;, 									RecordType.DeveloperName = &apos;INT_Deployment&apos;, 									RecordType.DeveloperName = &apos;NUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;QUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;SP_Deployment&apos; 					),     Business_Analyst__c != null     				 	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Complete Data In %28Actual%29 is entered</fullName>
        <actions>
            <name>Compass_Complete_Data_In_Actual_is_entered</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This sends an email to the BA when the Complete Data In (Actual) is assigned on Compass Deployment record types.</description>
        <formula>AND (      NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Deployment__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 					OR ( 					    RecordType.DeveloperName = &apos;USC_Deployment&apos;, 									RecordType.DeveloperName = &apos;INT_Deployment&apos;, 									RecordType.DeveloperName = &apos;NUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;QUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;SP_Deployment&apos; 					),     C_A_CDI__c != null    					 	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Auto Populate Engineer Lead - International Spend_Surgery and ED</fullName>
        <actions>
            <name>Compass_Update_Engineer_Lead_4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field &quot;Engineer Lead&quot; will be auto-populated based off the Deployment Type - International Spend, International Surgery, International ED</description>
        <formula>( Deployment_Type__r.Name = &quot;International Spend&quot;)  ||  (Deployment_Type__r.Name = &quot;International Surgery&quot;)  ||  (Deployment_Type__r.Name =&quot;International ED&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Auto Populate Engineer Lead - SP_SCI_Spend</fullName>
        <actions>
            <name>Compass_Update_Engineer_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field &quot;Engineer Lead&quot; will be auto-populated based off the Deployment Type - SCI, Surgical Probability or Spend.</description>
        <formula>( Deployment_Type__r.Name = &quot;Surgical Profitability&quot;)  ||  (Deployment_Type__r.Name = &quot;Spend&quot;)  ||  (Deployment_Type__r.Name =&quot;SCI&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Auto Populate Engineer Lead - USC</fullName>
        <actions>
            <name>Compass_Update_Engineer_Lead_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field &quot;Engineer Lead&quot; will be auto-populated based off the Deployment Type - USC</description>
        <formula>( Deployment_Type__r.Name = &quot;USC&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Initial Site Build Complete Actual is entered</fullName>
        <actions>
            <name>Compass_Initial_Site_Build_Complete_Actual_is_entered</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This sends an email to the BA when the Initial Site Build Complete (Actual) is entered on Compass Deployment record types.</description>
        <formula>AND (      NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Deployment__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 					OR ( 					    RecordType.DeveloperName = &apos;USC_Deployment&apos;, 									RecordType.DeveloperName = &apos;INT_Deployment&apos;, 									RecordType.DeveloperName = &apos;NUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;QUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;SP_Deployment&apos; 					),      C_A_ISBC__c != null					 	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Internal Validation Complete Actual is entered</fullName>
        <actions>
            <name>Compass_Internal_Validation_Complete_Actual_is_entered</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This sends an email to the BA when the Internal Validation Complete (Actual) is entered on Compass Deployment record types.</description>
        <formula>AND (      NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Deployment__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ), 					OR ( 					    RecordType.DeveloperName = &apos;USC_Deployment&apos;, 									RecordType.DeveloperName = &apos;INT_Deployment&apos;, 									RecordType.DeveloperName = &apos;NUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;QUBI_Deployment&apos;, 									RecordType.DeveloperName = &apos;SP_Deployment&apos; 					),      C_A_IVC__c != null    					 	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deployment Name Auto-Populate</fullName>
        <actions>
            <name>Autopopulate_Deployment_Name_All_Types</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>SSC Academic Planning,SSC Navigate Deployment</value>
        </criteriaItems>
        <description>This workflow auto-populates the Deployment Name - as per CR-20120208-384</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Configuration Complete %28Expected%29 and Site Live %28Expected%29</fullName>
        <actions>
            <name>Update_Configuration_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Site_Live_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( RecordType.DeveloperName  =&apos;APS_Deployment&apos;,        Use_Standard_Milestone_Goals__c = true ,       Deployment_Type__r.Name =&apos;APS&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Deployment Name SSC Academic Planning RType</fullName>
        <actions>
            <name>Populate_Deployment_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SSC Academic Planning</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Deployment Sign Off %28Expected%29 For APS and SSC Navigate</fullName>
        <actions>
            <name>Update_Deployment_Sign_Off_Expected_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>created via CR-20201007-14586</description>
        <formula>AND(     NOT(ISBLANK(RecordTypeId)),      OR(         RecordType.Name  = &apos;SSC Navigate Deployment&apos;,         RecordType.Name = &apos;APS Deployment&apos;        ),        OR( ISNEW(),  ISCHANGED( C_A_DS__c ),            ISCHANGED(RecordTypeId)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Deployment Sign Off %28Expected%29 field</fullName>
        <actions>
            <name>Update_Deployment_Sign_Off_Expected_fi</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SSC Navigate Deployment</value>
        </criteriaItems>
        <description>Created for CR-20210203-14868</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates</fullName>
        <actions>
            <name>Update_Data_Diag_Comp_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Expected_Recurring_Update_Sign_Of</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Internal_Validation_Comp_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>pdate_Expected_TechU_Planning_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_2</fullName>
        <actions>
            <name>Update_Complete_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Site_Build_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Technical_Planning_Call_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_UAT_Onsite_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment,Compass Connect Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_3</fullName>
        <actions>
            <name>CC_Site_Build_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CC_Complete_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CC_Initial_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment,CMA Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_4</fullName>
        <actions>
            <name>Project_Planning_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked. Added as part of CR-3241</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_9</fullName>
        <actions>
            <name>Update_Deployment_Sign_Off_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Site_Live_Expected_FOR_ssc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SSC Deployment,Compass Connect Deployment</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
