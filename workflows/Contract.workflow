<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_AmendmentOpportunityRecordTypeId</fullName>
        <field>SBQQ__AmendmentOpportunityRecordTypeId__c</field>
        <formula>$Label.Opportunity_RT_ID_EAB_Initiating
/** SBQQ__Opportunity__r.Original_Opportunity_RecordTypeId__c **/</formula>
        <name>FU_AmendmentOpportunityRecordTypeId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Preserve_Bundle_True</fullName>
        <description>Updates Preserve Bundle Structure to true</description>
        <field>SBQQ__PreserveBundleStructureUponRenewals__c</field>
        <literalValue>1</literalValue>
        <name>FU_Preserve_Bundle_True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_RenewalOpportunityRecordTypeId</fullName>
        <field>SBQQ__RenewalOpportunityRecordTypeId__c</field>
        <formula>CASE(LOWER(SBQQ__Opportunity__r.RecordType.Name),
  LOWER($Label.Opportunity_RT_Name_EAB_Continuing), $Label.Opportunity_RT_ID_EAB_Continuing,
  LOWER($Label.Opportunity_RT_Name_EAB_Initiating), $Label.Opportunity_RT_ID_EAB_Continuing,
  
  /*LOWER($Label.Opportunity_RT_Name_HC_Continuing), $Label.Opportunity_RT_ID_HC_Continuing,
  LOWER($Label.Opportunity_RT_Name_HC_Initiating), $Label.Opportunity_RT_ID_HC_Continuing,*/
  $Label.Opportunity_RT_ID_EAB_Continuing
)</formula>
        <name>FU_RenewalOpportunityRecordTypeId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_RenewalOpportunityRenewalPricebookId</fullName>
        <description>Field update to populate &quot;Renewal Pricebook Id&quot; field on contract record with the Opportunity Price book Id.</description>
        <field>SBQQ__RenewalPricebookId__c</field>
        <formula>SBQQ__Opportunity__r.Pricebook2Id</formula>
        <name>FU_RenewalOpportunityRenewalPricebookId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Renewal_Opportunity_Stage</fullName>
        <field>SBQQ__RenewalOpportunityStage__c</field>
        <formula>&apos;Pending&apos;</formula>
        <name>FU_Update_Renewal_Opportunity_Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Amendment_Start_Date</fullName>
        <field>SBQQ__AmendmentStartDate__c</field>
        <formula>StartDate</formula>
        <name>Update Amendment Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Amendment Start Date</fullName>
        <actions>
            <name>Update_Amendment_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the amendment start date when a Standard Contract is created.</description>
        <formula>AND(   NOT( ISBLANK( StartDate ) ),   OR(     ISNEW(),     ISCHANGED(StartDate)   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_AmendmentOpportunityRecordTypeId</fullName>
        <actions>
            <name>FU_AmendmentOpportunityRecordTypeId</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_RenewalOpportunityRecordTypeId</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_RenewalOpportunityRenewalPricebookId</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Update_Renewal_Opportunity_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( 	NOT(ISNULL(SBQQ__Opportunity__c)), 	OR( 		ISNEW(), 		ISCHANGED(SBQQ__Opportunity__c) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Preserve_Bundle_True</fullName>
        <actions>
            <name>FU_Preserve_Bundle_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.SBQQ__PreserveBundleStructureUponRenewals__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Sets preserve bundle structure to true on Standard Contract.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
