<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Chairman_s_Team_Assignment_Email</fullName>
        <description>Chairman&apos;s Team Assignment Email</description>
        <protected>false</protected>
        <recipients>
            <field>CT_Assignment_s_Manager_Email__c</field>
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
            <recipient>jmaydak@eab.com.eab</recipient>
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
        <recipients>
            <field>Research_Strategic_Leader__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Chairman_s_Team/New_Chairman_s_Team_Assignment_Subscription_Period</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update</fullName>
        <field>Stage_Latest_Period_New__c</field>
        <formula>TEXT(Stage__c)</formula>
        <name>Update Stage (Latest Period) field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Program_Subscription__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Pool_Date_Text_field</fullName>
        <description>Created for CR-20190501-13073</description>
        <field>PoolDateText__c</field>
        <formula>(TEXT(Pool_Date__c))</formula>
        <name>Update Pool Date (Text) field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Previous_Period_Negotiated_Credit</fullName>
        <description>Created for CR-20190501-13073</description>
        <field>PreviousPeriodNegotiatedCreditText__c</field>
        <formula>(TEXT(Previous_Period_Negotiated_Credit__c))</formula>
        <name>Update Previous Period Negotiated Credit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Pool Date %28Text%29 field</fullName>
        <actions>
            <name>Update_Pool_Date_Text_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20190501-13073</description>
        <formula>ISCHANGED(Pool_Date__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Previous Period Negotiated Credit %28Text%29 field</fullName>
        <actions>
            <name>Update_Previous_Period_Negotiated_Credit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20190501-13073</description>
        <formula>ISCHANGED(Previous_Period_Negotiated_Credit__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Stage %28Latest Period%29 field</fullName>
        <actions>
            <name>Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Subscription_Period__c.Period_Start_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription_Period__c.Period_End_Date__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription_Period__c.Stage__c</field>
            <operation>notEqual</operation>
            <value>Void</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Chairman_Team_Assignment</fullName>
        <actions>
            <name>Chairman_s_Team_Assignment_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow rule to generate an email. If a product is passed to chairman&apos;s team via subscription period. Created for CR-20180126-11912.</description>
        <formula>AND ( 	 	NOT(  		  		AND($Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,  			 			OR( 				 				CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Subscription_Period__c&quot;),   				CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)  			 			)  		 		)  	 	), 	ISPICKVAL(CT_Pass_Status__c, &apos;Assigned&apos;),   	NOT(RecordType.DeveloperName = &apos;Royall&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
