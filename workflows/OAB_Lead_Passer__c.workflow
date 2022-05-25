<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_PopulateOABLeadPasserName</fullName>
        <description>Created as per CR-20140904-7233.</description>
        <field>Name</field>
        <formula>IF(
  
   OR ( 
      ISNULL (Passer__c), 
      ISBLANK (Passer__c) 
    ),
	LEFT(&apos;null&apos;+ &apos;-&apos; + Warm_Lead__r.Name, 80),
    LEFT(Passer__r.LastName + &apos; -&apos; + Warm_Lead__r.Name, 80)
)</formula>
        <name>FU_PopulateOABLeadPasserName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateWarmLeadQualificationToQualified</fullName>
        <description>Update Warm lead Qualification Status to Qualified</description>
        <field>Qualification_Status__c</field>
        <literalValue>Qualified</literalValue>
        <name>UpdateWarmLeadQualificationToQualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Warm_Lead__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateWarmLeadQualificationToUnQualified</fullName>
        <description>Update warm lead qualification status to unqualified.</description>
        <field>Qualification_Status__c</field>
        <literalValue>Unqualified</literalValue>
        <name>UpdateWarmLeadQualificationToUnQualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Warm_Lead__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>ValidateWarmLeadQualifiedStatus</fullName>
        <actions>
            <name>UpdateWarmLeadQualificationToQualified</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OAB_Lead_Passer__c.Qualified__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>OAB_Lead_Passer__c.Lead_Count_2__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ValidateWarmLeadUnQualifiedStatus</fullName>
        <actions>
            <name>UpdateWarmLeadQualificationToUnQualified</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OAB_Lead_Passer__c.Qualified__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>OAB_Lead_Passer__c.Lead_Count_2__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulateOABLeadPasserName</fullName>
        <actions>
            <name>FU_PopulateOABLeadPasserName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OAB_Lead_Passer__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Created as per CR-20140904-7233.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
