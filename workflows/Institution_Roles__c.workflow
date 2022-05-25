<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Institution_Role_Name_Update</fullName>
        <description>Set Institution Role Name = Contact Name - Role</description>
        <field>Name</field>
        <formula>LEFT(Assignment_Role__r.Name, 40) +  &quot; - &quot;  + LEFT(Institution__r.Account_Formal_Name__c, 37)</formula>
        <name>Institution Role Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unchecked_Interim_Field</fullName>
        <field>Interim_Contact__c</field>
        <literalValue>0</literalValue>
        <name>Unchecked Interim Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Institution Role Name</fullName>
        <actions>
            <name>Institution_Role_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISNEW() || ISCHANGED(Name) || ISCHANGED(Contact__c) || ISCHANGED(Assignment_Role__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unchecked Interim Contact When Contact Is Changed</fullName>
        <actions>
            <name>Unchecked_Interim_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created with respect to CR-20211025-15546</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS(UPPER($Setup.Bypass_Logic__c.Objects_to_Bypass__c), &quot;INSTITUTION_ROLES__C&quot;), CONTAINS(UPPER($Setup.Bypass_Logic__c.Objects_to_Bypass__c), &quot;ALL&quot;) ) ) ), ( AND( PRIORVALUE(Interim_Contact__c), ISCHANGED(Contact__c) ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
