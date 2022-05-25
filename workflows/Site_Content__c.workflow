<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Site_Content_Name_Update</fullName>
        <description>Populates the name of the Site Content record to match the Title.</description>
        <field>Name</field>
        <formula>LEFT(Title__c, 80)</formula>
        <name>Site Content Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Site Content Name</fullName>
        <actions>
            <name>Site_Content_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the name of Site Content records.</description>
        <formula>Name &lt;&gt; LEFT(Title__c, 80)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
