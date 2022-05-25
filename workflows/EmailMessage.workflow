<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Replied_from_Email</fullName>
        <description>This updates the case status for Level 1, Level 2, and Community case records types if client replies via email.  This update is for APAC and US.</description>
        <field>Status</field>
        <literalValue>Replied</literalValue>
        <name>Updates case status to replied (email)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_Update_Post_7_days</fullName>
        <description>Updates field, email - post 7 days, with the email message.</description>
        <field>Email_Comment_Post_14_days__c</field>
        <formula>TextBody</formula>
        <name>Email_Update - Post 14 days custom</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Email_Re_Open_Case_Status</fullName>
        <description>Created for CR-20140827-7164. Will be applicable for re-opening of already closed cases.</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>FU_Email_Re_Open_Case_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Mail_update</fullName>
        <field>New_Mail__c</field>
        <literalValue>1</literalValue>
        <name>New Mail update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Response_Time_to_True2</fullName>
        <field>Initial_Response_Time2__c</field>
        <literalValue>1</literalValue>
        <name>Update Initial Response Time to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_case_status_to_re_opened2</fullName>
        <description>Updates case status to reopened if a client responds to a closed case via email within 7 days of case being closed.</description>
        <field>Status</field>
        <literalValue>Reopened</literalValue>
        <name>Update case status to re-opened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>New Case Mail</fullName>
        <actions>
            <name>New_Mail_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Updates Initial Response Time via Email Message</fullName>
        <actions>
            <name>Update_Initial_Response_Time_to_True2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the Initial Response Time checkbox to true. This is used to help track Initial Response Time.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;EmailMessage&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ),  (  AND ( OR( ToAddress  &lt;&gt; &apos;counselorcommunity@eab.com&apos;,ToAddress  &lt;&gt; &apos;intersectsupport@eab.com&apos;,ToAddress  &lt;&gt; &apos;starfishsupport@eab.com&apos;,ToAddress  &lt;&gt; &apos;applicationsupport@eab.com&apos; ),  CreatedBy.Profile.Name  &lt;&gt; &apos;Salesforce Administrator&apos;,  DATEVALUE(Parent.CreatedDate) &gt;=  DATE(2016,5,8))  ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Updates case status to closed when client responds via email %28HE and K12%29</fullName>
        <actions>
            <name>Email_Update_Post_7_days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates field, email/comment - post 14 days, if client responds to a case (via email) that has been closed for more than 14 days.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;EmailMessage&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND ( Incoming = True, ISPICKVAL ( Parent.Status , &quot;Closed&quot;), OR ( Parent.RecordType.DeveloperName = &quot;Intersect&quot;, Parent.RecordType.DeveloperName = &quot;Intersect_APS&quot;, Parent.RecordType.DeveloperName = &quot;APS_Review&quot;, Parent.RecordType.DeveloperName = &quot;Counselor_Community&quot;, Parent.RecordType.DeveloperName = &quot;Starfish&quot;), ( TODAY() &gt;= DATEVALUE( Parent.ClosedDate )+15)) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Updates case status to reopened when client responds via email %28HE and K12%29</fullName>
        <actions>
            <name>Update_case_status_to_re_opened2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates case status to reopened if client responds to a case (via email) within 14 days of the case closing.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;EmailMessage&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND ( Incoming = True, ISPICKVAL ( Parent.Status , &quot;Closed&quot;), OR ( Parent.RecordType.DeveloperName = &quot;Intersect&quot;, Parent.RecordType.DeveloperName = &quot;Intersect_APS&quot;, Parent.RecordType.DeveloperName = &quot;APS_Review&quot;, Parent.RecordType.DeveloperName = &quot;Counselor_Community&quot;, Parent.RecordType.DeveloperName = &quot;Starfish&quot;,Parent.RecordType.DeveloperName = &quot;Technical_Support&quot;), ( TODAY() &lt;= DATEVALUE( Parent.ClosedDate )+14)) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Updates case status to reopened when client responds via email %28Projects%29</fullName>
        <actions>
            <name>Update_case_status_to_re_opened2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates case status to reopened if client responds to a case (via email) within 30 days of the case closing.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;EmailMessage&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND ( Incoming = True, ISPICKVAL ( Parent.Status , &quot;Closed&quot;), Parent.RecordType.DeveloperName = &quot;Projects&quot;, ( TODAY() &lt;= DATEVALUE( Parent.ClosedDate )+30)) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Updates case status to replied when client responds via email %28HE and K12%29</fullName>
        <actions>
            <name>Case_Replied_from_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the case status to Replied if client  responds to a case via email.</description>
        <formula>AND( NOT( AND( $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c, OR( CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;EmailMessage&quot;), CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;) ) ) ), ( AND ( Incoming = True, NOT(ISPICKVAL ( Parent.Status , &quot;New&quot;)), OR(Parent.RecordType.DeveloperName = &quot;Projects&quot;, Parent.RecordType.DeveloperName = &quot;APS_Review&quot;, Parent.RecordType.DeveloperName = &quot;Counselor_Community&quot;, Parent.RecordType.DeveloperName = &quot;Intersect&quot;, Parent.RecordType.DeveloperName = &quot;Intersect_APS&quot;, Parent.RecordType.DeveloperName = &quot;Starfish&quot;, Parent.RecordType.DeveloperName = &quot;Technical_Support&quot;), Parent.IsClosed = False ) ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_Email_Re_Opens_Support_Case</fullName>
        <actions>
            <name>FU_Email_Re_Open_Case_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140827-7164.</description>
        <formula>AND ( Incoming = true,  Parent.IsClosed = true,  Parent.RecordType.DeveloperName = &quot;Member_Employee_Support&quot;, Parent.Owner:Queue.DeveloperName = &quot;Events_Member_Support&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
