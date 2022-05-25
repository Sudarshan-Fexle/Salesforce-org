<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Update_Creative_Package_Name</fullName>
        <description>Created via CR-20210323-15016</description>
        <field>Name</field>
        <formula>&apos;CPKG-&apos;+  IF(NOT(ISBLANK(Art_File_Name__c)), LEFT(Art_File_Name__c,Find(&quot;.&quot;, Art_File_Name__c)-1), &apos;null&apos;)</formula>
        <name>FU Update Creative Package Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF Update Creative Package Name</fullName>
        <actions>
            <name>FU_Update_Creative_Package_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created via CR-20210323-15016</description>
        <formula>OR(ISCHANGED(Art_File_Name__c),ISNEW())</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
