<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Check_Discount</fullName>
        <field>Discount__c</field>
        <literalValue>1</literalValue>
        <name>FU_Check_Discount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Populate_Job_Number</fullName>
        <description>Created for the CR-20170221-10712.</description>
        <field>Name</field>
        <formula>IF(ISPICKVAL(Target_Audience_New__c,&apos;Advancement Accounts&apos;),
Program_Package__r.Account__r.School_Code_Advancement__c, 
Program_Package__r.Account__r.r_School_Code__c)
&amp; 
RIGHT(Program_Package__r.Fiscal_Year__c, 2) &amp;

Campaign_Code__c</formula>
        <name>FU_Populate_Job_Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_OptOut_On_Status_PendingOptOut</fullName>
        <description>Created for CR-20170331-10803.</description>
        <field>Opt_Out__c</field>
        <literalValue>1</literalValue>
        <name>FU_Update_OptOut_On_Status_PendingOptOut</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Probability_to_0_on_Declined</fullName>
        <description>Sets a the Program Probability to 0 when the Program Status is set to Declined</description>
        <field>Probability__c</field>
        <formula>0</formula>
        <name>Set Probability to 0 on Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Probability_to_100_on_Contract</fullName>
        <description>Sets a the Program &apos;Close Probability&apos; to 100% when the Program Status is set to &apos;Contracted&apos; OR &apos;Pending Signature&apos;</description>
        <field>Probability__c</field>
        <formula>1</formula>
        <name>&apos;Probability&apos; to 100%:Status=Con OR PS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lock_the_Record_True</fullName>
        <field>Lock_the_Record__c</field>
        <literalValue>1</literalValue>
        <name>Update Lock the Record =True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Program Contracted or Pending Sig</fullName>
        <actions>
            <name>Set_Probability_to_100_on_Contract</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Contracted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Signature</value>
        </criteriaItems>
        <description>Program (R) - This rule automatically updates the field &apos;PROBABILITY&apos; to = &quot;100%&quot; when &apos;STATUS&apos; = &quot;Contracted&quot; OR &quot;Pending Signature&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Program Declined</fullName>
        <actions>
            <name>Set_Probability_to_0_on_Declined</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Declined</value>
        </criteriaItems>
        <description>Triggers updates when a program is declined</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Lock the Record when Status %3D Contracted</fullName>
        <actions>
            <name>Update_Lock_the_Record_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Contracted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update_Opt_Out_On_Status_Pending_Opt_Out</fullName>
        <actions>
            <name>FU_Update_OptOut_On_Status_PendingOptOut</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending - Opt Out</value>
        </criteriaItems>
        <criteriaItems>
            <field>Royall_Program__c.Opt_Out_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Royall_Program__c.Opt_Out__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Check_Discount</fullName>
        <actions>
            <name>FU_Check_Discount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Royall_Program__c.Campaign_New__c</field>
            <operation>equals</operation>
            <value>Discount - No Campaign</value>
        </criteriaItems>
        <description>Created for the CR-20170221-10712.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Populate_Job_Number</fullName>
        <actions>
            <name>FU_Populate_Job_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for the CR-20170221-10712.</description>
        <formula>IF( ISNEW(), true, OR(ISCHANGED( Campaign_New__c ), ISCHANGED(Target_Audience_New__c) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
