<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Request_status_field_to_Approved</fullName>
        <description>Update request status field based on the action that agent performs.</description>
        <field>Request_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Request status field to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Request_status_field_to_Rejected</fullName>
        <description>set the request status field to rejected</description>
        <field>Request_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Request status field to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
