<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Eval_Response_Question</fullName>
        <field>Eval_Question_Text__c</field>
        <formula>Eval_Question__r.Question_Name__c</formula>
        <name>Eval Response Question</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF Rule%3A Eval Response Question</fullName>
        <actions>
            <name>Eval_Response_Question</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISBLANK( Eval_Question__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
