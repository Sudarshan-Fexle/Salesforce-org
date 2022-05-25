<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_Collection_Contents</fullName>
        <field>Name</field>
        <formula>IF( 
	NOT(ISBLANK(Program__c)),
	Program__r.Name,
	IF(
		NOT(ISBLANK(Program_Collection__c)),
		Program_Collection__r.Name,
		Name
	)
)</formula>
        <name>FU Rename Collection Contents</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_Collection_Contents</fullName>
        <actions>
            <name>FU_Rename_Collection_Contents</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>OR( 	AND( 		ISNEW(),   		OR( 			NOT(ISBLANK(Program__c)), 			NOT(ISBLANK(Program_Collection__c)) 		)  	), 	AND( 		OR( 			ISCHANGED(Name), 			ISCHANGED(Program__c), 			ISCHANGED(Program_Collection__c) 		)  	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
