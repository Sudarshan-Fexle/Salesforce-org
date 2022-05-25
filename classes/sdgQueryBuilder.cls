/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 global with sharing class sdgQueryBuilder {
public  class sdgInvalidFilterException extends sdgException {}
    
global static string BuildSortClause (String sortColumn, String sortOrder){
    system.debug('Sort Order: ' + SortOrder);
    system.debug('Sort Column: ' + SortColumn);
            
    String sSortClause = '';
    if (String.isNotBlank(sortColumn))
    {
        if (sortOrder == 'A')
            sSortClause = ' ORDER BY ' + sortColumn + ' ASC NULLS FIRST';
        else
            sSortClause = ' ORDER BY ' + sortColumn + ' DESC NULLS LAST';
    }
    return sSortClause;
}

global static string BuildFilterClause(String ColumnName, String FieldType, String filterOperator, String filterValue)
{
    String sClause = '';
    String colName = String.escapeSingleQuotes(ColumnName);

    if (string.isblank(filteroperator))
        filteroperator = '=';
    
    if (FieldType ==String.valueof(Schema.DisplayType.MULTIPICKLIST))
    {
        system.debug('@@multi-filtervalue.trim():' + filtervalue.trim() + '--operator:' + filteroperator);
        if (String.isNotBlank(filtervalue.trim()))
        {
            //Added By Mahendra - Starts from here
            List<String> listFiltervalues = new List<String>();  
            String filtervaluesInStringFormate = '';
            
            if(!filtervalue.endsWithIgnoreCase('NULL') && filtervalue.length() > 0 
               && FieldType ==String.valueof(Schema.DisplayType.MULTIPICKLIST)
              ){ 
                  for(String filtr : filtervalue.split(',')){
                      
                      if(String.isNotBlank(filtr.trim())){
                          listFiltervalues.add(filtr);
                          filtervaluesInStringFormate = filtervaluesInStringFormate + '\''+filtr.trim()+'\',';   
                      }
                  }
                  filtervaluesInStringFormate = filtervaluesInStringFormate.trim().removeEnd(',').trim();
                  system.debug('@@@@ listFiltervalues' + listFiltervalues + ' @@@@ filtervaluesInStringFormate' + filtervaluesInStringFormate);
              }
            //Added By Mahendra - Ends here
            
            if (filteroperator=='=') {
                //if filter contains key word (ie: null), treat it as if the filter is null without quotes
                if (filtervalue.equalsIgnoreCase('NULL')) {
                    sclause =  colName + ' = null ';                            
                }
                else {
                    
                    if(listFiltervalues.size() > 0){
                        sclause =  colName + ' INCLUDES (' + filtervaluesInStringFormate + ')';   
                    } else {
                        sclause =  colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\' ';    
                    }
                }
            }
            if (filteroperator=='NOT=') {
                
                //if filter contains key word (ie: null), treat it as if the filter is null without quotes
                if (filtervalue.equalsIgnoreCase('NULL')) {
                    sclause =  colName + ' != null ';                            
                }
                else {
                    if(listFiltervalues.size() > 0){
                        sclause =  colName + ' EXCLUDES (' + filtervaluesInStringFormate + ')';   
                    } else {
                        sclause =  colName + ' != \'' + String.escapeSingleQuotes(filtervalue) + '\' ';
                    }
                }
            }
            if (filteroperator=='CONTAINS'){
                if(listFiltervalues.size() > 0){
                    sclause =  colName + ' INCLUDES (' + filtervaluesInStringFormate + ')';   
                } else {
                    sclause =  colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\' ';    
                }
            }
            
            if (filteroperator=='NOTCONTAINS'){
                
                if(listFiltervalues.size() > 0){
                    sclause =  colName + ' EXCLUDES (' + filtervaluesInStringFormate + ')';   
                } else {
                    sclause =  colName + ' != \'' + String.escapeSingleQuotes(filtervalue) + '\' ';
                }  
            }
            if (filteroperator=='STARTS') {
                
                if(listFiltervalues.size() > 0){
                    sclause =  colName + ' INCLUDES (' + filtervaluesInStringFormate + ')';   
                } else {
                    sclause =  colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\' ';    
                }  
            }
            if (filteroperator=='ENDS') {
                
                if(listFiltervalues.size() > 0){
                    sclause =  colName + ' INCLUDES (' + filtervaluesInStringFormate + ')';   
                } else {
                    sclause =  colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\' ';    
                }  
            }
        }
        system.debug('@@@sclause:' + sclause);
    }
    
    if (FieldType ==String.valueof(Schema.DisplayType.STRING ) || FieldType ==String.valueof(Schema.DisplayType.PICKLIST))
    {
        
        if (String.isNotBlank(filtervalue.trim()))
        {
            //Added By Mahendra - Starts from here
            List<String> listFiltervalues = new List<String>();  
            String filtervaluesInStringFormate = '';
            
            if(!filtervalue.endsWithIgnoreCase('NULL') && filtervalue.contains(',') 
               && (colName == 'RecordType.Name' || FieldType ==String.valueof(Schema.DisplayType.PICKLIST))
              ){ 
                  for(String filtr : filtervalue.split(',')){
                      
                      if(String.isNotBlank(filtr.trim())){
                          listFiltervalues.add(filtr);
                          filtervaluesInStringFormate = filtervaluesInStringFormate + '\''+filtr.trim()+'\',';   
                      }
                  }
                  filtervaluesInStringFormate = filtervaluesInStringFormate.trim().removeEnd(',').trim();
                  system.debug('@@@@ listFiltervalues' + listFiltervalues + ' @@@@ filtervaluesInStringFormate' + filtervaluesInStringFormate);
              }
            //Added By Mahendra - Ends here
            
            if (filteroperator=='=') {
                //if filter contains key word (ie: null), treat it as if the filter is null without quotes
                if (filtervalue.equalsIgnoreCase('NULL')) {
                    sclause =  colName + ' = null ';                            
                }
                else {
                    
                    if(listFiltervalues.size() > 0){
                        sclause =  colName + ' IN (' + filtervaluesInStringFormate + ')';   
                    } else {
                        sclause =  colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\' ';    
                    }
                }
            }
            if (filteroperator=='NOT=') {
                
                //if filter contains key word (ie: null), treat it as if the filter is null without quotes
                if (filtervalue.equalsIgnoreCase('NULL')) {
                    sclause =  colName + ' != null ';                            
                }
                else {
                    if(listFiltervalues.size() > 0){
                        sclause =  colName + ' Not IN (' + filtervaluesInStringFormate + ')';   
                    } else {
                        sclause =  colName + ' != \'' + String.escapeSingleQuotes(filtervalue) + '\' ';
                    }
                }
            }
            if (filteroperator=='CONTAINS'){
                if(listFiltervalues.size() > 0) {
                    sclause = '';
                    for(String filtr : listFiltervalues){
                        
                        sclause = sclause+  colName + ' like \'%' + String.escapeSingleQuotes(filtr) + '%\'' + ' OR ';   
                    }
                    sclause = sclause.removeEnd(' OR ').trim();
                } else {
                    sclause =  colName + ' like \'%' + String.escapeSingleQuotes(filtervalue) + '%\'';
                }
            }
            
            if (filteroperator=='NOTCONTAINS'){
                
                if(listFiltervalues.size() > 0) {
                    sclause = '';
                    for(String filtr : listFiltervalues){
                        sclause = sclause + ' (NOT ' + colName + ' like \'%' + String.escapeSingleQuotes(filtr) + '%\') ' + ' OR '; 
                    }
                    sclause = sclause.removeEnd(' OR ').trim();
                } else {
                    
                    sclause = ' (NOT ' + colName + ' like \'%' + String.escapeSingleQuotes(filtervalue) + '%\') ';
                }   
            }
            if (filteroperator=='STARTS') {
                
                if(listFiltervalues.size() > 0) {
                    sclause = '';
                    for(String filtr : listFiltervalues){
                        sclause = sclause + colName + ' like \'' + String.escapeSingleQuotes(filtr) + '%\' '+ ' OR '; 
                    }
                    sclause = sclause.removeEnd(' OR ').trim();
                } else {
                    
                    sclause = colName + ' like \'' + String.escapeSingleQuotes(filtervalue) + '%\' ';
                }   
            }
            if (filteroperator=='ENDS') {
                
                
                if(listFiltervalues.size() > 0) {
                    sclause = '';
                    for(String filtr : listFiltervalues){
                        sclause = sclause + colName + ' like \'%' + String.escapeSingleQuotes(filtr) + '\' '+' OR '; 
                    }
                    sclause = sclause.removeEnd(' OR ').trim();
                } else {
                    
                    sclause = colName + ' like \'%' + String.escapeSingleQuotes(filtervalue) + '\' ';
                }   
            }
        }
    }
    if (FieldType ==String.valueof(Schema.DisplayType.BOOLEAN))
    {
        Set<String> booleanvalues = new set<String>{'true', 'false', ''};
            if (!booleanvalues.contains(filtervalue))
        {
            throw new SDGInvalidFilterException('Invalid date filter value provided');
        }
        if (filtervalue=='true')
        {
            sclause = colName + ' = true ';
        }
        if (filtervalue == 'false')
        {
            sclause = colName + ' = false ';
        }
    }
    if (FieldType ==String.valueof(Schema.DisplayType.INTEGER) || (FieldType ==String.valueof(Schema.DisplayType.CURRENCY)) || (FieldType ==String.valueof(Schema.DisplayType.PERCENT)) || FieldType ==String.valueof(Schema.DisplayType.DOUBLE))
    {
        if ((String.isNotBlank(filtervalue) && (String.isNotBlank(filtervalue.trim()) )))
        {
            
            if (filteroperator=='=')
                sclause = colName + ' = ' + String.escapeSingleQuotes(filtervalue) + ' ';
            
            if (filteroperator=='GT')
                sclause = colName + ' > ' + String.escapeSingleQuotes(filtervalue) + ' ';
            
            if (filteroperator=='LT')
                sclause = colName + ' < ' + String.escapeSingleQuotes(filtervalue) + ' ';
            
        }
    }
    if (FieldType ==String.valueof(Schema.DisplayType.DATE) || FieldType==String.valueof(Schema.DisplayType.DATETIME))
    {
        Set<String> datevalues = new set<String>{'=', 'LT', 'GT'};
            Set<String> literaldatevalues = new set<String>{'THIS_WEEK', 'LAST_WEEK', 'NEXT_WEEK', 'TODAY', 'TOMORROW', 'YESTERDAY',  
                'NEXT_MONTH','THIS_MONTH', 'LAST_MONTH', 'LAST_QUARTER', 'THIS_QUARTER', 'NEXT_QUARTER', 'LAST_YEAR', 'THIS_YEAR', 'NEXT_YEAR',
                'NEXT_N_DAYS:7', 'LAST_N_DAYS:7', 'LAST_N_DAYS:30'};
                    if (literaldatevalues.contains(filteroperator))
                {
                    sclause = colName + ' = ' + filteroperator + ' ';
                    
                }
        else
        {
            if (datevalues.contains(filteroperator))
            {
                //we need to parse it as a date
                if (String.isNotBlank(filtervalue.trim()) )
                {
                    Date dateval = Date.today();
                    
                    Boolean DateOK =false;
                    String StringDate ='';
                    try
                    {
                        
                        List<String> dateparts = filtervalue.split('-');
                        Date dt = date.newInstance(Integer.valueOf(dateparts[0]),Integer.valueof(dateparts[1]),Integer.valueof(dateparts[2]));
                        DateOK = true;
                        //now convert to string:
                        StringDate = dt.year() + '-' + String.valueOf(dt.month()).leftpad(2).replaceall(' ','0')  + '-' + String.valueOf(dt.day()).leftpad(2).replaceall(' ','0') ;
                        String startDay = stringDate + 'T00:00:00Z'; //start
                        String endDay = StringDate + 'T23:59:59Z';//end of the day
                        
                        if (DateOK)
                        {
                            if (filteroperator=='=')
                            {
                                if (FieldType==String.valueof(Schema.DisplayType.DATE))
                                {
                                    sclause = colName + ' = ' + StringDate + ' ';
                                }
                                else
                                {
                                    sclause = colName + ' > ' + startDay + ' ';
                                    sclause = colName + ' < ' + endDay + ' ';
                                }
                            }
                            if (filteroperator=='GT')
                                if (FieldType==String.valueof(Schema.DisplayType.DATE))
                            {
                                sclause = colName+ ' > ' + StringDate + ' ';
                            }
                            else
                            {
                                sclause =  colName + ' > ' + endDay + ' ';
                                
                            }
                            if (filteroperator=='LT')
                                if (FieldType==String.valueof(Schema.DisplayType.DATE))
                            {
                                sclause =  colName + ' < ' + StringDate + ' ';
                            }
                            else
                            {
                                sclause = colName + ' < ' + startDay + ' ';
                            }
                        }
                        
                    }
                    catch (Exception ex)
                    {
                        Throw new SDGInvalidFilterException('Invalid date provided');
                        
                    }
                }
            }
        }
        
    } //End of date handler

    		/* //Commented By Mahendra as it is covered in the String type case.
            if (FieldType ==String.valueof(Schema.DisplayType.PICKLIST))
            {
                if (!String.isblank(filtervalue))
                {
                    sclause = colName + ' = \'' + String.escapeSingleQuotes(filtervalue) + '\'';
                }
            }
           */ 
    sclause = ' ' + sclause.trim() + ' ';
    system.debug('@@@@@@ sclause' + sclause);
    
    return sClause;
    }
    
    public static string ProcessMergeFields(String query, String ParentRecordID)
    {
        String mergedquery = query.replaceall('#userid#', '\'' + UserInfo.getUserId() + '\'');
        if (!String.isBlank(ParentRecordID))
        {
            mergedquery = mergedquery.replaceall('#Id#',  String.escapeSingleQuotes(ParentRecordID) );
        }
        return mergedquery;
    }
}