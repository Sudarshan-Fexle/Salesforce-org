<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autoname_Rule_Program</fullName>
        <field>Name</field>
        <formula>RecordType.Name + &quot;-&quot; + LEFT(Program__r.Name, 63)</formula>
        <name>Autoname - Rule - Program</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Autoname_Rule_Threshold</fullName>
        <field>Name</field>
        <formula>RecordType.Name + &quot;-&quot; +  TEXT( Threshold_Type__c ) + &quot;-&quot;
+ IF( Threshold_Number__c &gt; 0 ,  TEXT( Threshold_Number__c ) ,  TEXT( Threshold_Percent__c ) )</formula>
        <name>Autoname - Rule - Threshold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Autoname_Rule_Title</fullName>
        <field>Name</field>
        <formula>RecordType.Name + &quot;-&quot; +  TEXT( Job_Function__c )</formula>
        <name>Autoname - Rule - Title</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Is_Industry</fullName>
        <description>Set Industry = true</description>
        <field>Industry__c</field>
        <literalValue>1</literalValue>
        <name>Is Industry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Autoname - Rule - Program</fullName>
        <actions>
            <name>Autoname_Rule_Program</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Rule__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Program</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Autoname - Rule - Threshold</fullName>
        <actions>
            <name>Autoname_Rule_Threshold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Rule__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Threshold</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Autoname - Rule - Title</fullName>
        <actions>
            <name>Autoname_Rule_Title</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Rule__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Title</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Identify as Industry</fullName>
        <actions>
            <name>Is_Industry</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the selected Program’s Available Segments indicates this is an Industry program, then flag the rule as such. Do not indicate False, only True.</description>
        <formula>INCLUDES(Program__r.Applicable_Segments__c, &quot;US HCIC&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
