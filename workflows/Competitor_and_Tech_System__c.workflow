<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Tech_Name_field</fullName>
        <description>Created w.r.t CR-20211118-15596</description>
        <field>Name</field>
        <formula>IF
(RecordType.Name = &apos;Internal System&apos;, 
 System__r.Name,
 Tech_Name__r.Name
)</formula>
        <name>Update Tech Name field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Tech Name field</fullName>
        <actions>
            <name>Update_Tech_Name_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created w.r.t CR-20211118-15596</description>
        <formula>AND(  NOT(  AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,  OR( CONTAINS(UPPER($Setup.Bypass_Logic__c.Objects_to_Bypass__c), &quot;COMPETITOR_AND_TECH_SYSTEM__C&quot;), CONTAINS(UPPER($Setup.Bypass_Logic__c.Objects_to_Bypass__c), &quot;ALL&quot;)  )  )  ),  (   OR( AND(     RecordType.Name = &apos;Internal System&apos;,     OR(ISCHANGED( System__c ),NOT(ISBLANK( System__c )))     ),     OR(ISCHANGED(Tech_Name__c),NOT(ISBLANK( Tech_Name__c )))    ) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
