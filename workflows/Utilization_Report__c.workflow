<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Studybuilder_Record_Name_FU</fullName>
        <description>Field Update which updates the name of Studybuilder Output records</description>
        <field>Name</field>
        <formula>LEFT(Report_Institution__r.Account_Formal_Name__c, 54) + 
&quot; - &quot; + 
TEXT(MONTH(Report_Start_Date__c)) + &quot;/&quot; + TEXT(DAY(Report_Start_Date__c)) + &quot;/&quot; + TEXT(YEAR(Report_Start_Date__c)) + 
&quot; - &quot; + 
TEXT(MONTH(Report_End_Date__c)) + &quot;/&quot; + TEXT(DAY(Report_End_Date__c)) + &quot;/&quot; + TEXT(YEAR(Report_End_Date__c))</formula>
        <name>Update Studybuilder Record Name FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Studybuilder Ouput Record Name</fullName>
        <actions>
            <name>Update_Studybuilder_Record_Name_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Utilization_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Utilization Report Output</value>
        </criteriaItems>
        <description>This workflow rule updates the Studybuilder Name to follow a designated pattern.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
