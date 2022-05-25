<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PSE_Set_IsServices_Flag_On_Opp_Products</fullName>
        <field>pse__IsServicesProductLine__c</field>
        <literalValue>1</literalValue>
        <name>PSE Set IsServices Flag On Opp Products</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PSA Set Opportunity Product IsServicesProductLine Flag</fullName>
        <actions>
            <name>PSE_Set_IsServices_Flag_On_Opp_Products</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.pse__IsServicesProduct__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow will look at the product that has been added to the opportunity product line item. If the product is a services product it will check the check box on the opportunity product line item.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
