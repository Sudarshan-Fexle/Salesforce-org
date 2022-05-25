<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Revenue_field</fullName>
        <field>Revenue__c</field>
        <formula>YearlyRevenueAmount__c</formula>
        <name>Update Revenue field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>FirmName__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Yearly_Profit_field</fullName>
        <field>CurrentYearProfit__c</field>
        <formula>YearlyProfit__c</formula>
        <name>Update Current Year Profit field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>FirmName__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_current_retention_rate_field</fullName>
        <field>RetentionRate__c</field>
        <formula>RetentionRate__c</formula>
        <name>Update current retention rate field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>FirmName__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_of_clients_field</fullName>
        <field>ofCustomers__c</field>
        <formula>Current__c</formula>
        <name>Update # of clients field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>FirmName__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_of_employees_field</fullName>
        <field>ofEmployees__c</field>
        <formula>Currentofemployees__c</formula>
        <name>Update # of employees field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>FirmName__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update Firm fields from Yearly Statistics</fullName>
        <actions>
            <name>Update_Revenue_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Yearly_Profit_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_current_retention_rate_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_of_clients_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_of_employees_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TEXT(FiscalYear__c) = $Label.Yearly_Statistics_Year</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
