<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Zendesk_Support_Alert</fullName>
        <ccEmails>eabtechsupport@eab.com</ccEmails>
        <description>Zendesk Support Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Application_Support/Zendesk_Support_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Account Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateAccountOwner</fullName>
        <description>Upon account create/edit update the Account Owner to Salesforce Admin User</description>
        <field>OwnerId</field>
        <lookupValue>sfadmin@eab.com.eab</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>FU_UpdateAccountOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateVendorAccountOwnerWithEAB</fullName>
        <description>Created for CR-20170929-11627</description>
        <field>OwnerId</field>
        <lookupValue>indigoeab@eab.com.eab</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>FU_UpdateVendorAccountOwnerWithEAB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Research_Platform_Date_field</fullName>
        <field>Platinum_Member_Date__c</field>
        <formula>IF(ISBLANK(TEXT(Research_Platform__c)), null, NOW())</formula>
        <name>FU_Update Research Platform Date field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetStrategicAccountNameWithTopParent</fullName>
        <description>Update Strategic Account Name with Institution Top Parent</description>
        <field>Strategic_Account_Name__c</field>
        <formula>Top_Parent_Name_Text__c</formula>
        <name>SetStrategicAccountNameWithTopParent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_City</fullName>
        <field>BillingCity</field>
        <formula>Primary_City__c</formula>
        <name>Vendor: Update Billing City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_Country</fullName>
        <field>BillingCountry</field>
        <formula>TEXT(Primary_Country__c)</formula>
        <name>Vendor: Update Billing Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_State_Province</fullName>
        <field>BillingState</field>
        <formula>TEXT(Primary_State_Province__c)</formula>
        <name>Vendor: Update Billing State/Province</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_Street</fullName>
        <description>If Primary Address Lines 1, 2 and 3 are populated then we should add these as necessary to the Billing Street field.</description>
        <field>BillingStreet</field>
        <formula>IF(
NOT(ISBLANK(Primary_Address_Line_1__c)) &amp;&amp; NOT(ISBLANK(Primary_Address_Line_2__c)) &amp;&amp;
NOT(ISBLANK(Primary_Address_Line_3__c)),
Primary_Address_Line_1__c + &apos;, &apos; + Primary_Address_Line_2__c + &apos;, &apos; + Primary_Address_Line_3__c,
IF(
NOT(ISBLANK(Primary_Address_Line_1__c)) &amp;&amp; NOT(ISBLANK(Primary_Address_Line_2__c)),
Primary_Address_Line_1__c + &apos;, &apos; + Primary_Address_Line_2__c,
IF(
NOT(ISBLANK(Primary_Address_Line_1__c)),
Primary_Address_Line_1__c,
NULL)))</formula>
        <name>Vendor: Update Billing Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_Zipcode</fullName>
        <field>BillingPostalCode</field>
        <formula>Primary_Postal_Code__c</formula>
        <name>Vendor: Update Billing Zipcode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Account Historical Linker</fullName>
        <actions>
            <name>Account_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;),  OR(  Historical_Linker__c=&quot;&quot; ,  Historical_Linker__c &lt;&gt; Counter_ID__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Zendesk Support Notification</fullName>
        <actions>
            <name>Zendesk_Support_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends an email to eabtechsupport@eab.com reminding them to update the corresponding Organization record in Zendesk with the Counter ID from the Institution</description>
        <formula>AND(     Zendesk_Support__c,     CONTAINS($Organization.Id, &apos;0hhu6&apos;) 
  /*last part of production org id, because full org id gets auto-updated in sandboxes.  
  Only send if in production so sandbox tests dont trigger email to ZD support*/
  
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SetStrategicAccountNameWithTopParent</fullName>
        <actions>
            <name>SetStrategicAccountNameWithTopParent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNULL( Strategic_Account_Name__c), ISBLANK(Strategic_Account_Name__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update_Research_Platform_Date</fullName>
        <actions>
            <name>FU_Update_Research_Platform_Date_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Research Platform Date field when Research Platform is updated per CR-10949</description>
        <formula>OR(    ISNEW(),  ISCHANGED(Research_Platform__c)   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Vendor%3A Populate BillingState Addresses</fullName>
        <actions>
            <name>Vendor_Update_Billing_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_State_Province</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_Zipcode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( RecordType.Name = &apos;Vendor&apos;, OR( NOT(ISBLANK(Primary_Address_Line_1__c)), NOT(ISBLANK(Primary_Address_Line_2__c)), NOT(ISBLANK(Primary_Address_Line_3__c)), NOT(ISBLANK(Primary_City__c)), NOT(ISBLANK(TEXT(Primary_State_Province__c))), NOT(ISBLANK(Primary_Postal_Code__c)), NOT(ISBLANK(TEXT(Primary_Country__c))), ISCHANGED(Primary_Address_Line_1__c), ISCHANGED(Primary_Address_Line_2__c), ISCHANGED(Primary_Address_Line_3__c), ISCHANGED(Primary_City__c), ISCHANGED(Primary_State_Province__c), ISCHANGED(Primary_Postal_Code__c), ISCHANGED(Primary_Country__c) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateAccountOwner</fullName>
        <actions>
            <name>FU_UpdateAccountOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>User.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Vendor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IsPartner</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateVendorAccountOwnerWithEAB</fullName>
        <actions>
            <name>FU_UpdateVendorAccountOwnerWithEAB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Vendor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IsPartner</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Entity__c</field>
            <operation>equals</operation>
            <value>EAB</value>
        </criteriaItems>
        <description>Created for CR-20170929-11627.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
