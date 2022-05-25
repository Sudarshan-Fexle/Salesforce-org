<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Interaction_Chain</fullName>
        <description>If the Source Interaction field is populated, set field equal to value of Interaction Chain on parent record plus 1.  Otherwise, set Interaction Chain to 0.</description>
        <field>Interaction_Chain__c</field>
        <formula>IF ( NOT( ISBLANK( Source_Interaction__c ) ),
     1 + IF( ISBLANK(Source_Interaction__r.Interaction_Chain__c), 
            0, Source_Interaction__r.Interaction_Chain__c),
    0
)</formula>
        <name>Set Interaction Chain</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Interaction Chain</fullName>
        <actions>
            <name>Set_Interaction_Chain</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When a new Relationship Interaction record is created, this rule is run.</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
