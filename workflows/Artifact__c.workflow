<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PT_Ready_for_Print_Digital</fullName>
        <ccEmails>EnrollmentServicesMailServices@eab.com</ccEmails>
        <description>PT: Ready for Print Digital</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/Artifact_Ready_for_Print_Digital</template>
    </alerts>
    <fieldUpdates>
        <fullName>Artifact_Name</fullName>
        <description>Updates artifact name</description>
        <field>Name</field>
        <formula>TEXT(Type__c) &amp; &quot; : Drop &quot; &amp; TEXT(Production_Tracking__r.Drop__c)</formula>
        <name>Artifact: Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AT%3A Success - Digital Ready for Print</fullName>
        <actions>
            <name>PT_Ready_for_Print_Digital</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Fire when Artifact transfer succeeds.</description>
        <formula>AND( ISPICKVAL(Job_Ticket__r.Vendor_Type__c,&apos;Digital&apos;), ISPICKVAL(Type__c, &apos;Mailing List Validation Result&apos;), ISCHANGED(Status__c), ISPICKVAL(Status__c, &quot;Success&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF Rule%3A Artifact Name</fullName>
        <actions>
            <name>Artifact_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Artifact Name</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
