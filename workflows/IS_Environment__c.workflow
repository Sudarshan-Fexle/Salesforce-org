<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IS_Env_Update_Status_Available</fullName>
        <description>set Status to &apos;Available&apos; on Retention Date, and to notify EM</description>
        <field>Status__c</field>
        <literalValue>Available</literalValue>
        <name>IS Env Update Status Available</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IS Env Set Status Available</fullName>
        <active>true</active>
        <description>Timed Workflow - When Retention Date is set, set a field update to set Status to &apos;Available&apos; on Retention Date, and to notify EM</description>
        <formula>AND(   NOT( ISBLANK(Retention_Date__c) ),   NOT( ISPICKVAL( Status__c , &quot;Deleted&quot;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>IS_Env_Update_Status_Available</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>IS_Environment__c.Retention_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IS Env Update End Date</fullName>
        <active>true</active>
        <description>When Status is changed to Deleted or Deactivated, update the End Date on the record to the current date</description>
        <formula>ISCHANGED( Status__c ) &amp;&amp;  (ISPICKVAL( Status__c, &quot;Deleted&quot; ) || ISPICKVAL( Status__c, &quot;Deactivated&quot; ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
