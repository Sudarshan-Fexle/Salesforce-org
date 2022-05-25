<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_UpdateNowTrue</fullName>
        <field>Update_Now__c</field>
        <literalValue>1</literalValue>
        <name>FU_UpdateNowTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_UpdateTrendingData</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 and 4</booleanFilter>
        <criteriaItems>
            <field>Intranet_Container__c.Container_Type__c</field>
            <operation>equals</operation>
            <value>SubContainer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Intranet_Container__c.Content_Types_Allowed__c</field>
            <operation>includes</operation>
            <value>Trending - Advisory.com,Trending - EAB.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Intranet_Container__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Intranet_Container__c.Update_Now__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FU_UpdateNowTrue</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Intranet_Container__c.Last_Content_Update__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
