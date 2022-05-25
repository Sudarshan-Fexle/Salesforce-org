<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EA_Approved_by_Legal</fullName>
        <description>Approved by Legal</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ET_ContractExceptnRequestApprovedByLegal</template>
    </alerts>
    <alerts>
        <fullName>EA_Review_Required_CPQ_Exception_Request</fullName>
        <description>Review Required: CPQ Exception Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>legaluser@eab.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ET_CPQ_Exception_Requests</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_LegalRecordTypeUpdated</fullName>
        <description>New Record type that gets updated when the picklist value gets changed to &apos;Request Legal approval&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>Legal</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FU_LegalRecordTypeUpdated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_CPQExceptionRequest_ApprovedByLegal</fullName>
        <actions>
            <name>EA_Approved_by_Legal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CPQ_Exception_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Legal</value>
        </criteriaItems>
        <criteriaItems>
            <field>CPQ_Exception_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved by Legal</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_CPQExceptionRequest_RequestLegalApproval</fullName>
        <actions>
            <name>EA_Review_Required_CPQ_Exception_Request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FU_LegalRecordTypeUpdated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CPQ_Exception_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Request Legal Approval</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
