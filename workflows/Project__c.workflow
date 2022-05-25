<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autopopulate_Project_Name</fullName>
        <field>Name</field>
        <formula>IF( RecordType.DeveloperName == &quot;ES_Project&quot;, 

(IF( LEN(Institution__r.Name) &gt; 60, LEFT(Institution__r.Name, 60), Institution__r.Name) + &quot; - &quot; + IF(LEN(Product__r.Program_Acronym__c) &gt; 7, LEFT(Product__r.Program_Acronym__c, 7), Product__r.Program_Acronym__c) + &quot; - &quot; + Fiscal_Year__c), 

(IF( LEN(Institution__r.Name) &gt; 70, LEFT(Institution__r.Name, 70), Institution__r.Name) + &quot; - &quot; + IF(LEN(Product__r.Program_Acronym__c) &gt; 9 , LEFT(Product__r.Program_Acronym__c, 9), Product__r.Program_Acronym__c))


)</formula>
        <name>Autopopulate Project Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Project_Name</fullName>
        <field>Project_Name_2__c</field>
        <formula>Institution__r.Name  &amp; &quot; - &quot; &amp;   Product__r.Name</formula>
        <name>Project Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Created Date not equal to Null</fullName>
        <actions>
            <name>Project_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Project Name to Member - Product</fullName>
        <actions>
            <name>Autopopulate_Project_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will auto-populate the Project Number similiar to how the Project Name is populated (Member - Product)</description>
        <formula>ISNEW() ||  ( ISCHANGED(Institution__c ) || ISCHANGED( Product__c) || ISCHANGED( Fiscal_Year__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateDateEnteredValueStream</fullName>
        <active>false</active>
        <formula>OR (  				ISPICKVAL(Project_Phase__c, &apos;5 - Value Stream&apos;),     ISPICKVAL(Project_Phase__c, &apos;Value Stream&apos;)    )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
