<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LIS_Comment_for_Travel</fullName>
        <description>populate the Line Item Comment with Amount if type=Travel</description>
        <field>Line_Item_Comment__c</field>
        <formula>&quot;Travel Fee &quot; &amp;&quot;$&quot; &amp; TEXT( Invoice_Amount__c * Contract_Exchange_Rate__c )</formula>
        <name>LIS Comment for Travel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LIS_Invoiced_update_record_type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Line_Item_Schedule_Invoiced</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>LIS Invoiced-update record type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LIS_Populate_Amount</fullName>
        <field>Amount__c</field>
        <formula>IF( Contract_Currency__c =&quot;USD&quot;,  Invoice_Amount__c ,    Invoice_Amount__c    *  Contract_Exchange_Rate__c )</formula>
        <name>LIS Populate Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LIS Invoiced-update record type</fullName>
        <actions>
            <name>LIS_Invoiced_update_record_type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item_Schedule__c.Invoiced__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LIS Populate Amount</fullName>
        <actions>
            <name>LIS_Populate_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item_Schedule__c.Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If amount field blank for Member Fees, calculate the amount based on invoice amount, currency and exchange rate.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LIS-TravelFee-UpdateComment</fullName>
        <actions>
            <name>LIS_Comment_for_Travel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Line_Item_Schedule__c.Type__c</field>
            <operation>equals</operation>
            <value>Travel</value>
        </criteriaItems>
        <criteriaItems>
            <field>Line_Item_Schedule__c.Line_Item_Comment__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Add Amount to LIS Comment if type=Travel Fee</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
