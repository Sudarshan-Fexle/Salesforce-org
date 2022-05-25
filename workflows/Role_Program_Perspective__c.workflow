<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Change_Record_Type_On_Creation</fullName>
        <description>Change the record type to “Assigned”</description>
        <field>RecordTypeId</field>
        <lookupValue>Assigned</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FU Change Record Type On Creation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Populate_End_Date</fullName>
        <field>Effective_End__c</field>
        <formula>Staff_Assignment__r.End_date__c</formula>
        <name>FU_Populate_End_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Rename_Role_Program_Perspective</fullName>
        <field>Name</field>
        <formula>LEFT((Staff_Assignment__r.Name+&quot;-&quot;+Program_Perspective__r.Name), 80)</formula>
        <name>FU Rename Role Program Perspective</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Change_Record_Type_On_Creation</fullName>
        <actions>
            <name>FU_Change_Record_Type_On_Creation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Change the record type of an SA record upon creation.</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_Populate_End_Date</fullName>
        <actions>
            <name>FU_Populate_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Role_Program_Perspective__c.Effective_End__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Team_Membership__c.End_date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Rename_Role_Program_Perspective</fullName>
        <actions>
            <name>FU_Rename_Role_Program_Perspective</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>Name &lt;&gt; Staff_Assignment__r.Name+&quot;-&quot;+Program_Perspective__r.Name</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
