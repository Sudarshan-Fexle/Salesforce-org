<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_PL_Opportunity_Stage</fullName>
        <description>Updates the Product Lead&apos;s &quot;Opportunity: Stage&quot; from the associated Opportunity</description>
        <field>Opportunity_Stage__c</field>
        <formula>TEXT(Opportunity__r.StageName)</formula>
        <name>Populate PL Opportunity: Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Product Lead%3A Opportunity Stage Update</fullName>
        <actions>
            <name>Populate_PL_Opportunity_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Product Lead&apos;s &quot;Opportunity: Stage&quot; when the Opportunity lookup is set or changed.</description>
        <formula>NOT(ISBLANK(Opportunity__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
