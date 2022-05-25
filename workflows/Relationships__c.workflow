<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Count_Total_Score_fields</fullName>
        <field>Count_of_Total_Score_Fields__c</field>
        <formula>( 
IF( 
ISBLANK(TEXT(StrongStrategicRationale__c)), 
0,1) + 
IF( 
ISBLANK(TEXT(DifferentiatedCapability__c)), 
0,1) + 
IF( 
ISBLANK(TEXT(BusinessModelAlignment__c)), 
0,1) + 
IF( 
ISBLANK(TEXT(MaterialFinancialImpact__c)), 
0,1) + 
IF( 
ISBLANK(TEXT(FinanciallyAttractive__c)), 
0,1))</formula>
        <name>Count Total Score fields</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Count of Total Score fields</fullName>
        <actions>
            <name>Count_Total_Score_fields</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( 
ISNEW(),
ISCHANGED(StrongStrategicRationale__c), 
ISCHANGED(DifferentiatedCapability__c), 
ISCHANGED(BusinessModelAlignment__c), 
ISCHANGED(MaterialFinancialImpact__c), 
ISCHANGED(FinanciallyAttractive__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
