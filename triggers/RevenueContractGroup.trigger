// UNAMANAGED TRIGGER - DO NOT ADD TO PACKAGE
trigger RevenueContractGroup on Revenue_Contract_Group__c (before delete) 
{
    ffps_eab.RevContractGroupRemover revContGrpRemover = new ffps_eab.RevContractGroupRemover( trigger.oldmap.keyset());
    revContGrpRemover.deleteRevGroups(false);
    
    // Add Errors for rcg that cannot have the RCG removed
    for( Revenue_Contract_Group__c rcg :  trigger.old )
    {
        if( revContGrpRemover.revGrpIdWithRevenue_set.contains(rcg.id) )
        {
            rcg.addError('You cannot remove Revenue Group as Revenue has already been applied.');
        }
    }
}