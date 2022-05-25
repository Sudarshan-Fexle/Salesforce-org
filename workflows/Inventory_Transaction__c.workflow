<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EA_Notify_On_Difference_In_Between_Shipped_Received_Quantities</fullName>
        <description>EA_Notify_On_Difference_In_Between_Shipped_Received_Quantities</description>
        <protected>false</protected>
        <recipients>
            <recipient>shalu.sharma@fexle.com.eab</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Print_Mgt_Email_Templates/EA_Notify_On_Difference_In_Between_Shipped_Received_Quantities</template>
    </alerts>
    <rules>
        <fullName>WF_Notify_On_Difference_In_Between_Shipped_Received_Quantities</fullName>
        <actions>
            <name>EA_Notify_On_Difference_In_Between_Shipped_Received_Quantities</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow Rule to notify Mail Shop team when &quot;Inventory Shipped&quot; and &quot;Inventory Received&quot; differs. Created via CR-20210525-15180.</description>
        <formula>AND ( 				NOT(ISNEW()),     NOT(ISBLANK(Quantity_Shipped__c)), 				NOT(ISBLANK(Quantity_Received__c)), 				OR ( 				    ISCHANGED(Quantity_Shipped__c), 								ISCHANGED(Quantity_Received__c)     ), 				Quantity_Shipped__c  &lt;&gt; Quantity_Received__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
