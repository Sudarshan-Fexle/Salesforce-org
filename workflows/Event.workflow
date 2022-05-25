<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cappex_Customer_Survey_Results_Notification</fullName>
        <description>Cappex Customer Survey Results Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>aolson@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>astepien@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chunter@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>japril@collegegreenlight.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jcampbell@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tsingh@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cappex_Email_Templates/Cappex_Customer_Satsfctn_Survey_Response</template>
    </alerts>
    <fieldUpdates>
        <fullName>Auto_Populate_Description_Field</fullName>
        <description>There is a feature called Timeline in Gainsight that lists all events related to an account; however, events only sync to Gainsight if they have a value in the Description field. Soo, Description Field Update is created.</description>
        <field>Description</field>
        <formula>&quot;Event description automatically populated. You may override this description&quot;</formula>
        <name>Auto_Populate Description Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Event_Department_Subject</fullName>
        <field>Subject</field>
        <formula>TEXT(Event_Type__c) &amp; &quot; &quot; &amp; &quot;-&quot; &amp; &quot; &quot; &amp; Title__c</formula>
        <name>Event Department Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Event_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Event Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Exclude_From_Exchange_Synch</fullName>
        <description>Update default value for member success record type on Exclude From Exchange Synch field to true</description>
        <field>Exclude_From_Exchange_Synch__c</field>
        <literalValue>1</literalValue>
        <name>Update Exclude From Exchange Synch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Department Subject Auto-Populate</fullName>
        <actions>
            <name>Event_Department_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Dev</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Event_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto-populate the subject for eTech Dev record types</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Event Historical Linker</fullName>
        <actions>
            <name>Event_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;),  OR(  Historical_Linker__c=&quot;&quot; ,  Historical_Linker__c &lt;&gt; Counter_ID__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Gainsight Event Description Update</fullName>
        <actions>
            <name>Auto_Populate_Description_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.Description</field>
            <operation>equals</operation>
            <value>NULL</value>
        </criteriaItems>
        <description>Updates the field Description on Events if it is null</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Exclude From Exchange Synch</fullName>
        <actions>
            <name>Update_Exclude_From_Exchange_Synch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Member Success</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Exclude_From_Exchange_Synch__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update default value for member success record type on Exclude From Exchange Synch field to true</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>zzzSend Cappex Customer Survey Results</fullName>
        <actions>
            <name>Cappex_Customer_Survey_Results_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>CX QA Survey</value>
        </criteriaItems>
        <description>Created for CR-20210108-14794</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
