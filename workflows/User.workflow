<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Exclude_From_Auto_Subsc_to_Chatter_Group</fullName>
        <description>Created for CR-20170302-10732.</description>
        <field>Auto_Subscribe_to_Chatter_Groups__c</field>
        <literalValue>0</literalValue>
        <name>Exclude From Auto-Subsc to Chatter Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Populate_Entity_Via_Entity_Override</fullName>
        <description>Created for CR-20171006-11682.</description>
        <field>Entity__c</field>
        <formula>TEXT(Entity_Override__c)</formula>
        <name>FU_Populate_Entity_Via_Entity_Override</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Exclude Contractors From Chatter Autosubscribe</fullName>
        <actions>
            <name>Exclude_From_Auto_Subsc_to_Chatter_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Contractor__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created for CR-20170302-10732.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate_Entity_Via_Entity_Override</fullName>
        <actions>
            <name>FU_Populate_Entity_Via_Entity_Override</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20171006-11682.</description>
        <formula>AND (  					NOT( 									ISBLANK( 													TEXT(Entity_Override__c) 									) 					), 					Entity__c &lt;&gt; TEXT(Entity_Override__c)  	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
