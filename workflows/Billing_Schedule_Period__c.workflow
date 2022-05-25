<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>WF_BSP_Update_Name_Field</fullName>
        <field>Name</field>
        <formula>Billing_Schedule_Header__r.Name + &quot;-&quot; + 

CASE(TEXT(Billing_Schedule_Header__r.Invoicing_Arrangement__c),
                &quot;Annual&quot;, Fiscal_Year__c + &quot;-Ann&quot;, 
                &quot;Semi-Annual&quot;, Fiscal_Year__c + &quot;-Sem&quot;,
                &quot;Quarterly&quot;, Fiscal_Year__c + &quot;-Qtr&quot;,
                &quot;Monthly&quot;, Fiscal_Year__c + &quot;-Mon&quot;,
                &quot;ES-75-25&quot;, Fiscal_Year__c + &quot;-75/25&quot;,
                &quot;FYXXXX&quot;
)

+ &quot;- &quot; + TEXT(Installment__c)

+ IF (Reversal__c = TRUE, &quot;- R&quot;, &quot;&quot;)</formula>
        <name>WF_BSP_Update Name Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>BSP%3A Update Name Field</fullName>
        <actions>
            <name>WF_BSP_Update_Name_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
