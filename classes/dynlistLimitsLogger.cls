/*
Purpose         :   Dynamic Related List Limits Logger Class
Created By      :   Abhinav Sharma
Created Date    :   01/10/2022
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 01/10/2022
*/
public with sharing class dynlistLimitsLogger 
{
    public static Integer getMaxAllowedQueryRowsCount()
    {
        if(Limits.getQueryRows () >= Limits.getLimitQueryRows())
        {
        	return 0;   
        }
        else 
        {
			return (Limits.getLimitQueryRows() - Limits.getQueryRows ());            
        }
    }
}