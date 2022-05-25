<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IS_Comp_Update_Name_Field</fullName>
        <field>Name</field>
        <formula>/*IF(
NOT(ISBLANK(Parent__c)),
RecordType.DeveloperName + &quot;:&quot; + TEXT(Object_Type__c) + &quot;-&quot; +  Parent__r.Object_Label__c + &quot;-&quot; + Object_Label__c,
RecordType.DeveloperName + &quot;:&quot; + TEXT(Object_Type__c) + &quot;-&quot; + Object_Label__c
)*/
CASE(TEXT(Object_Type__c),
  &apos;Apex Class&apos;,&apos;Class&apos;,
  &apos;Visualforce Component&apos;,&apos;VFCompnt&apos;,
  &apos;Visualforce Page&apos;,&apos;VFPage&apos;,
  &apos;Apex Trigger&apos;,&apos;Trigger&apos;,
  &apos;App Menu&apos;,&apos;AppMenu&apos;,
  &apos;Approval Process&apos;,&apos;ApprProcess&apos;,
  &apos;Assignment Rule&apos;,&apos;AssgnRule&apos;,
  &apos;Auto-Response Rule&apos;,&apos;AutoRespRule&apos;,
  &apos;Connected App&apos;,&apos;ConnctApp&apos;,
  &apos;Custom Field&apos;,&apos;Field&apos;,
  &apos;Custom Label&apos;,&apos;CustomLabel&apos;,
  &apos;Custom Object&apos;,&apos;Object&apos;,
  &apos;Button/Link&apos;,&apos;ButtonLink&apos;,
  &apos;Custom Site&apos;,&apos;Site&apos;,
  &apos;Email Template&apos;,&apos;EmlTemplt&apos;,
  &apos;Flow Definition&apos;,&apos;Flow&apos;,
  &apos;Home Page Component&apos;,&apos;HomePgCompnt&apos;,
  &apos;Home Page Layout&apos;,&apos;HomePgLayout&apos;,
  &apos;Page Layout&apos;,&apos;PageLayout&apos;,
  &apos;List View&apos;,&apos;ListView&apos;,
  &apos;Live Agent Configuration&apos;,&apos;LvAgtConfig&apos;,
  &apos;Chat Button&apos;,&apos;ChatButton&apos;,
  &apos;Live Chat Deployment&apos;,&apos;LvChtDeploy&apos;,
  &apos;Permission Set&apos;,&apos;PermSet&apos;,
  &apos;Record Type&apos;,&apos;RecordType&apos;,
  &apos;Remote Site&apos;,&apos;RmtSite&apos;,
  &apos;Custom Report Type&apos;,&apos;CustRptType&apos;,
  &apos;Sharing Set&apos;,&apos;SharingSet&apos;,
  &apos;Static Resource&apos;,&apos;StatResource&apos;,
  &apos;Validation Rule&apos;,&apos;VR&apos;,
  &apos;Button or Link&apos;,&apos;ButtonLink&apos;,
  &apos;Workflow Email Alert&apos;,&apos;WFAlert&apos;,
  &apos;Workflow Rule&apos;,&apos;WFRule&apos;,
  &apos;Workflow Field Update&apos;,&apos;WFFldUpt&apos;,
  TEXT(Object_Type__c)) 
+ &quot;-&quot; + 
IF(LEN(Object_Label__c) &gt; 60,
  LEFT(Object_Label__c,60) + &quot;...&quot;,
  Object_Label__c)</formula>
        <name>IS Comp: Update Name Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Duplicate_Mgt_FU</fullName>
        <field>Duplicate_Matching__c</field>
        <formula>RIGHT(Object_API_Name__c , (LEN(Object_API_Name__c) - FIND(&quot;.&quot;, Object_API_Name__c)))</formula>
        <name>Populate Duplicate Mgt FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Populate Duplicate Management</fullName>
        <actions>
            <name>Populate_Duplicate_Mgt_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update IS Component Name</fullName>
        <actions>
            <name>IS_Comp_Update_Name_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1 = 1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
