<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FFRR_Create_Static_Value_for_Amort_End</fullName>
        <field>Cost_Amortization_End_Date_Static__c</field>
        <formula>Cost_Amortization_End_Date__c</formula>
        <name>FFRR Create Static Value for Amort End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Change_Reason_Code_Achieved</fullName>
        <description>Created for CR-20170907-11185.</description>
        <field>Change_Reason_Code__c</field>
        <literalValue>Site Live Date Achieved</literalValue>
        <name>FU_Update_Change_Reason_Code_Achieved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revenue_Populate_Account_Formal_Name</fullName>
        <description>This text field is used to help Finance team search for Revenue records by Account Formal Name</description>
        <field>Account_Formal_Name_Search__c</field>
        <formula>Institution__r.Account_Formal_Name__c</formula>
        <name>Revenue: Populate Account Formal Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Change_Reason_Code_Clone_To_Null</fullName>
        <description>Set null/blank as a value for Change_Reason_Code_Clone__c field.</description>
        <field>Change_Reason_Code_Clone__c</field>
        <name>Set_Change_Reason_Code_Clone_To_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Site_Live_Date_Changed_FU</fullName>
        <field>Site_Live_Date_Changed__c</field>
        <literalValue>1</literalValue>
        <name>Site Live Date Changed FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bypass_Trigger_Logic_Flag</fullName>
        <field>Bypass_Trigger_Logic__c</field>
        <literalValue>1</literalValue>
        <name>Update_Bypass_Trigger_Logic_Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>FFRR Update Cost Amortization End Date</fullName>
        <actions>
            <name>FFRR_Create_Static_Value_for_Amort_End</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ABC_Revenue__c.Cost_Amortization_End_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Create a &quot;date&quot; (not formula) value for amortization end date so that existing transactions are not affected if the value in average customer life on the product changes in subsequent years.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue%3A Populate Account Formal Name for Search</fullName>
        <actions>
            <name>Revenue_Populate_Account_Formal_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created to help the finance team search for Revenue records - formula fields cannot be used in enhanced search.</description>
        <formula>ISNEW() ||  ISCHANGED(Institution__c) ||  Account_Formal_Name__c != Account_Formal_Name_Search__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Revenue%3A Site Live Date Changed</fullName>
        <actions>
            <name>Site_Live_Date_Changed_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(ISNEW()), NOT(ISBLANK(PRIORVALUE(Site_Live_Date__c))), ISCHANGED(Site_Live_Date__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update_Change_Reason_Code_Clone</fullName>
        <actions>
            <name>Set_Change_Reason_Code_Clone_To_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bypass_Trigger_Logic_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ABC_Revenue__c.Change_Reason_Code_Clone__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>WF rule to set null/blank as a value for &quot;Change_Reason_Code_Clone__c&quot; field if it having non null/blank value with it. Created for CR-20170508-10905.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
