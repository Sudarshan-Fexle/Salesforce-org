<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Program_Fields_Edited</fullName>
        <description>Program Fields Edited</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfadmin@eab.com.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Program_Fields_Edited</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Invoice_City</fullName>
        <field>Invoice_City__c</field>
        <formula>&quot;Charlotte&quot;</formula>
        <name>Update Invoice City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Company_Name</fullName>
        <field>Invoice_Company_Name__c</field>
        <formula>&quot;EAB&quot;</formula>
        <name>Update Invoice Company Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Logo_URL</fullName>
        <field>Invoice_logo_URL__c</field>
        <formula>&quot;/servlet/servlet.FileDownload?file=015C0000002WEVw&quot;</formula>
        <name>Update Invoice Logo URL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_PostalCode</fullName>
        <field>Invoice_PostalCode__c</field>
        <formula>&quot;28260-3519&quot;</formula>
        <name>Update Invoice PostalCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_State</fullName>
        <field>Invoice_State__c</field>
        <formula>&quot;NC&quot;</formula>
        <name>Update Invoice State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Street_Address</fullName>
        <field>Invoice_Street_Address__c</field>
        <formula>&quot;P.O. Box 603519&quot;</formula>
        <name>Update Invoice Street Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Program Edits</fullName>
        <actions>
            <name>Program_Fields_Edited</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify IS when changes are made to program acronym or applicable segments</description>
        <formula>AND (     NOT(         AND(           $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,           OR(             CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Program__c&quot;),             CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)           )         )     ),	     OR( 				    ISCHANGED( Program_Acronym__c ),  				    ISCHANGED( Applicable_Segments__c )       ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Invoice fields when Program is created</fullName>
        <actions>
            <name>Update_Invoice_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Invoice_Company_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Invoice_Logo_URL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Invoice_PostalCode</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Invoice_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Invoice_Street_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Invoice fields when Program is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
