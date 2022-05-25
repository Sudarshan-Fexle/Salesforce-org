<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Subscription_Adjustment_DD_Rejected_Notification</fullName>
        <description>Subscription Adjustment DD Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Subscription_Adjustment_Templates/Deal_Desk_Approval</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Adjustment_Deal_Desk_Approved</fullName>
        <description>Subscription Adjustment Deal Desk Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Subscription_Adjustment_Templates/Subscription_Adjustment_DD_Approved</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Adjustment_Not_Approved_Notification</fullName>
        <description>Subscription Adjustment Not Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Subscription_Adjustment_Templates/Upload_Customer_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Subscription_Adjustment_Pending_DealDesk_Approval_Notification</fullName>
        <description>Subscription Adjustment Pending DealDesk Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Deal_Desk_approver</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Subscription_Adjustment_Templates/Deal_Desk_Approval</template>
    </alerts>
</Workflow>
