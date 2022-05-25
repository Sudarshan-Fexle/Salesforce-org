<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Update_Lead_Passer_Name</fullName>
        <description>Created via CR-20200804-14401</description>
        <field>Name</field>
        <formula>IF( AND(NOT(ISNULL(Passer__c)), NOT(ISNULL(X1EAB_Lead__c))),  
     LEFT(Passer__r.LastName,15) + &apos;-&apos; +  LEFT(X1EAB_Lead__r.Name,60) ,
     IF(AND(NOT(ISNULL(Passer__c)),ISNULL(X1EAB_Lead__c)), 
        Passer__r.LastName,
        IF(AND(ISNULL(Passer__c),NOT(ISNULL(X1EAB_Lead__c))), 
             X1EAB_Lead__r.Name, 
             &apos;&apos;
        ) 
     ) 
)</formula>
        <name>FU_Update_Lead_Passer_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Passer_Department</fullName>
        <description>Created via CR-20200804-14401</description>
        <field>Passer_Department__c</field>
        <formula>IF(NOT(ISNULL(Passer__c)) , Passer__r.Department, &apos;&apos;)</formula>
        <name>FU_Update_Passer_Department</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Passer_Manager</fullName>
        <description>created via CR-20200804-14401</description>
        <field>Passer_Manager__c</field>
        <formula>IF(NOT(ISNULL(Passer__c)), Passer__r.Manager.FirstName + &apos; &apos; + Passer__r.Manager.LastName, &apos;&apos;)</formula>
        <name>FU_Update_Passer_Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Passer_Role</fullName>
        <description>created via CR-20200804-14401</description>
        <field>Passer_Role__c</field>
        <formula>IF(NOT(ISNULL(Passer__c)), Passer__r.UserRole.Name , &apos;&apos;)</formula>
        <name>FU_Update_Passer_Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Passer_Title</fullName>
        <description>Created via CR-20200804-14401</description>
        <field>Passer_Title__c</field>
        <formula>IF(NOT(ISNULL(Passer__c)) ,Passer__r.Title , &apos;&apos;)</formula>
        <name>FU_Update_Passer Title</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Update_Lead_Passer_Name</fullName>
        <actions>
            <name>FU_Update_Lead_Passer_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>created via</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update_Passer_Details</fullName>
        <actions>
            <name>FU_Update_Passer_Department</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Update_Passer_Manager</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Update_Passer_Role</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Update_Passer_Title</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created via CR-20200804-14401</description>
        <formula>IF(OR(ISNEW(), ISCHANGED( Passer__c), ISCHANGED( Passer_Department__c), ISCHANGED(  Passer_Manager__c ), ISCHANGED(  Passer_Role__c ), ISCHANGED(  Passer_Title__c ) ), true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
