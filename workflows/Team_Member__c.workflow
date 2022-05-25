<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autoname_Team_Member_FU</fullName>
        <field>Name</field>
        <formula>IF( NOT(ISBLANK( Team_Member__c )), Team_Member__r.FirstName + &quot; &quot; + Team_Member__r.LastName + &quot; - &quot;, &quot;&quot;)
 + TEXT(Primary_Role__c)
 + IF( ISBLANK( Team_Member__c ), &quot; (undefined)&quot;, &quot;&quot;)</formula>
        <name>Autoname – Team Member FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Autoname %E2%80%93 Team Member</fullName>
        <actions>
            <name>Autoname_Team_Member_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Automatically names the Name value based on a concatenation of values.</description>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
