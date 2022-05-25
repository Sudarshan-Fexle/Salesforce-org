<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Auto_Populate_Opp_Sign_Off_Contact_Text</fullName>
        <description>Created for CR-20160401-9725.</description>
        <field>Opportunity_Sign_Off_Contact_Text__c</field>
        <formula>Value_Opportunity_Sign_Off_Contact__c</formula>
        <name>Auto Populate Opp Sign Off Contact Text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Approved_Results_equals_True</fullName>
        <field>Member_Approved_Results__c</field>
        <literalValue>1</literalValue>
        <name>Member Approved Results equals True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Autoopulate Member Approved Results as true</fullName>
        <actions>
            <name>Member_Approved_Results_equals_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity_and_ROI__c.ROI_Member_Sign_Off_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>The field &quot;Member Approved Date&quot; will be set as true if the &quot;Value Opportunity Member Sign Off Date&quot; field is not null.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Sync_Up_Opportunity_Sign_Off_Contact</fullName>
        <actions>
            <name>Auto_Populate_Opp_Sign_Off_Contact_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity_and_ROI__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Created for CR-20160401-9725.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
