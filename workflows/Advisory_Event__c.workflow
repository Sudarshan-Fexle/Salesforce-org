<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Location_Field_Update</fullName>
        <description>Update Location field with Virtual when Event Format is Virtual Only.</description>
        <field>Location__c</field>
        <formula>&apos;Virtual&apos;</formula>
        <name>FU_Location_Field_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateUltimateProgramParent</fullName>
        <field>Ultimate_Program_Parent__c</field>
        <formula>IF( 
AND ( 
ISPICKVAL(Rules_Programs__c, &quot;Use parent&apos;s rules&quot;), 
NOT(ISBLANK(Parent_Event__c)) 
), 
Parent_Event__r.Ultimate_Program_Parent__c, 
Id 
)</formula>
        <name>FU_PopulateUltimateProgramParent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateUltimateThresholdParent</fullName>
        <field>Ultimate_Threshold_Parent__c</field>
        <formula>IF( 
AND ( 
NOT(ISBLANK(Parent_Event__c)) 
), 
null,
Id 
				
)</formula>
        <name>FU_PopulateUltimateThresholdParent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateUltimateTitleParent</fullName>
        <field>Ultimate_Title_Parent__c</field>
        <formula>IF( 
AND ( 
ISPICKVAL(Rules_Programs__c, &quot;Use parent&apos;s rules&quot;), 
NOT(ISBLANK(Parent_Event__c)) 
), 
null, 
Id 
)</formula>
        <name>FU_PopulateUltimateTitleParent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Populate_Meeting_GUID</fullName>
        <description>Created for CR-20170509-10931.</description>
        <field>Meeting_GUID__c</field>
        <formula>&quot;AAAAAAAA-0000-0000-0000-0000&quot; &amp; 
CASE( LEN(RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8)), 
      1, &quot;0000000&quot; &amp; RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8),
      2, &quot;000000&quot; &amp; RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8),
      3, &quot;00000&quot; &amp; RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8),
      4, &quot;0000&quot; &amp; RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8),
      5, &quot;000&quot; &amp; RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8),
      6, &quot;00&quot; &amp; RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8),
      7, &quot;0&quot; &amp; RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8),
      RIGHT( SUBSTITUTE(Unique_Id__c, &apos;MN-&apos;, &apos;FFF&apos;), 8)
 )</formula>
        <name>FU_Populate_Meeting_GUID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateDateBegins</fullName>
        <field>Date_Begins__c</field>
        <formula>Begins__c</formula>
        <name>FU_UpdateDateBegins</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateDateEnds</fullName>
        <field>Date_Ends__c</field>
        <formula>Ends__c</formula>
        <name>FU_UpdateDateEnds</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Meeting_Autoname_Event_FU</fullName>
        <field>Name</field>
        <formula>LEFT(Short_Name__c + &quot; - &quot; + RecordType.Name +
CASE(
RecordType.Name,

&quot;Series&quot;, &quot; - &quot; + TEXT(YEAR(DATEVALUE(Begins__c))) + IF(YEAR( DATEVALUE(Ends__c) ) &lt;&gt; YEAR( DATEVALUE(Begins__c )), &quot;/&quot; + TEXT(YEAR(DATEVALUE(Ends__c))), &quot;&quot;),

&quot;Event&quot;, IF( NOT(ISBLANK(Parent_Event__c)), &quot; (&quot; + Parent_Event__r.Short_Name__c + &quot;)&quot;, &quot;&quot;) + &quot; - &quot; + TEXT(MONTH(DATEVALUE(Begins__c))) + &quot;/&quot; + TEXT(DAY(DATEVALUE(Begins__c))) + &quot;/&quot; + TRIM(RIGHT(TEXT(YEAR(DATEVALUE(Begins__c))), 2)) + IF(DATEVALUE(Ends__c) &lt;&gt; DATEVALUE(Begins__c), &quot; to &quot; + TEXT(MONTH(DATEVALUE(Ends__c))) + &quot;/&quot; + TEXT(DAY(DATEVALUE(Ends__c))) + &quot;/&quot; + TRIM(RIGHT(TEXT(YEAR( DATEVALUE(Ends__c))), 2)), &quot;&quot;),

&quot;Cohort&quot;, &quot; - &quot; + TEXT(MONTH(DATEVALUE(Begins__c))) + &quot;/&quot; + TEXT(DAY(DATEVALUE(Begins__c))) + &quot;/&quot; + TRIM(RIGHT(TEXT(YEAR(DATEVALUE(Begins__c))), 2)) + IF(DATEVALUE(Ends__c) &lt;&gt; DATEVALUE(Begins__c), &quot; to &quot; + TEXT(MONTH(DATEVALUE(Ends__c))) + &quot;/&quot; + TEXT(DAY(DATEVALUE(Ends__c))) + &quot;/&quot; + TRIM(RIGHT(TEXT(YEAR( DATEVALUE(Ends__c))), 2)), &quot;&quot;),

IF( NOT(ISBLANK(Parent_Event__c)), &quot; (&quot; + Parent_Event__r.Short_Name__c + &quot;)&quot;, &quot;&quot;) + &quot; - &quot; + TEXT(MONTH(DATEVALUE(Begins__c))) + &quot;/&quot; + TEXT(DAY(DATEVALUE(Begins__c))) + &quot;/&quot; + TRIM(RIGHT(TEXT(YEAR(DATEVALUE(Begins__c))), 2)) + IF(DATEVALUE(Ends__c) &lt;&gt; DATEVALUE(Begins__c), &quot; to &quot; + TEXT(MONTH(DATEVALUE(Ends__c))) + &quot;/&quot; + TEXT(DAY(DATEVALUE(Ends__c))) + &quot;/&quot; + TRIM(RIGHT(TEXT(YEAR( DATEVALUE(Ends__c))), 2)), &quot;&quot;)

), 80)</formula>
        <name>Meeting: Autoname Event FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Public_Name</fullName>
        <field>Public_Name__c</field>
        <formula>Short_Name__c</formula>
        <name>Populate Public Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Unique_Id</fullName>
        <field>Unique_Id__c</field>
        <formula>Event_Id__c</formula>
        <name>Populate Unique Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Advisory Event%3A Default Public Name</fullName>
        <actions>
            <name>Populate_Public_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Advisory_Event__c.Public_Name__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If the Public Name field is blank, populate with the Short Name.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Advisory Event%3A Update Unique Id</fullName>
        <actions>
            <name>Populate_Unique_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Advisory_Event__c.Unique_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Autoname %E2%80%93 Advisory Event</fullName>
        <actions>
            <name>Meeting_Autoname_Event_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Backfill Event Dates</fullName>
        <actions>
            <name>FU_UpdateDateBegins</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_UpdateDateEnds</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ensure that the Date Begins and Date Ends fields are populated based on the Begins and Ends date values</description>
        <formula>OR( 	AND( 		ISNEW(), 		OR( 			NOT(ISBLANK(Begins__c)), 			NOT(ISBLANK(Ends__c)) 		) 	), 	OR ( 		ISCHANGED(Begins__c), 		ISCHANGED(Ends__c) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Location_Update_On_EAB_Event</fullName>
        <actions>
            <name>FU_Location_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Advisory_Event__c.Location__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Advisory_Event__c.Event_Format__c</field>
            <operation>equals</operation>
            <value>Virtual</value>
        </criteriaItems>
        <description>This workflow rule is used to update the location field when Event format is Virtual Only.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulateUltimateTitleParent</fullName>
        <actions>
            <name>FU_PopulateUltimateProgramParent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Populate_Meeting_GUID</fullName>
        <actions>
            <name>FU_Populate_Meeting_GUID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20170509-10931.</description>
        <formula>AND(   OR(     RecordType.DeveloperName = &apos;Event&apos;,     RecordType.DeveloperName = &apos;Series&apos;,     RecordType.DeveloperName = &apos;Cohort&apos;   ),   OR(     ISBLANK(Meeting_GUID__c),     ISNEW()   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
