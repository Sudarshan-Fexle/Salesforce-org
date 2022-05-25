<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ShipIt_Delivery_Authorization_Reply_Authorized</fullName>
        <description>ShipIt Delivery Authorization Reply - Authorized</description>
        <protected>false</protected>
        <recipients>
            <field>Sender__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ShipIt/ShipIt_Delivery_Authorization_Reply_Accept</template>
    </alerts>
    <alerts>
        <fullName>ShipIt_Delivery_Authorization_Reply_Denied</fullName>
        <description>ShipIt Delivery Authorization Reply - Denied</description>
        <protected>false</protected>
        <recipients>
            <field>Sender__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ShipIt/ShipIt_Delivery_Authorization_Reply_Denied</template>
    </alerts>
    <alerts>
        <fullName>ShipIt_Delivery_Authorization_Request</fullName>
        <description>ShipIt Delivery Authorization Request</description>
        <protected>false</protected>
        <recipients>
            <field>Authorization_Requested_From__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Sender__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ShipIt/ShipIt_Delivery_Authorization_Request</template>
    </alerts>
    <rules>
        <fullName>Notify of Authorization - Authorized</fullName>
        <actions>
            <name>ShipIt_Delivery_Authorization_Reply_Authorized</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Runs when the Authorization Status is set to ‘Authorized&apos; on a Shipment record.
Used to notify the requesting user of the response.</description>
        <formula>AND ( 	  NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Shipment__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),   ISPICKVAL(Authorization_Status__c, &apos;Authorized&apos;)  	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify of Authorization - Denied</fullName>
        <actions>
            <name>ShipIt_Delivery_Authorization_Reply_Denied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Runs when the Authorization Status is set to ‘Denied’ on a Shipment record.
Used to notify the requesting user of the response.</description>
        <formula>AND ( 	  NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Shipment__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),   ISPICKVAL(Authorization_Status__c, &apos;Denied&apos;)  	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Request Authorization</fullName>
        <actions>
            <name>ShipIt_Delivery_Authorization_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Runs when the Status is set to ‘Pending
Authorization’ on a Shipment record.  Used to send a request for authorization to a specified user.</description>
        <formula>AND ( 	  NOT(     AND(       $Setup.Bypass_Logic__c.Bypass_Workflow_Rules__c,       OR(         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;Shipment__c&quot;),         CONTAINS($Setup.Bypass_Logic__c.Objects_to_Bypass__c, &quot;ALL&quot;)       )     )   ),   ISPICKVAL(Status__c, &apos;Pending Authorization&apos;)    	)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
