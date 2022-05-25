/*
Purpose         :   Field Factory (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistFieldFactory 
{
    public static Map<String, Dynamic_Related_List_Manager__mdt> mapOfObjectsNotHavingNameField = dynlistUtilities.mapOfObjectsNotHavingNameField();
    public static String parentFieldNameSettedInConfiguration = '';
    
    public static List<dynlistField> traverseFieldSet(
        Map<String, Schema.SObjectField> fieldsMap,
        String sOQLSelectFieldsString,
        Set<String> setOfNonQueryableFields,
        Set<String> setOfObjFieldNameWithType,
        String objectName
    ) 
    {
        List<dynlistField> listOfFieldDetails = new List<dynlistField>();
        for (String fieldName : sOQLSelectFieldsString.trim().split(dynlistConstants.CHAR_COMMA)) 
        {
            if(fieldsMap.get(fieldName.trim()) != null) 
            {
                Schema.DescribeFieldResult field = fieldsMap.get(fieldName.trim()).getDescribe();
                if(field.isAccessible()) 
                {
                    dynlistField fieldWrapper = dynlistFieldFactory.traverseField(field, setOfNonQueryableFields, setOfObjFieldNameWithType, objectName);
                    listOfFieldDetails.add(fieldWrapper);        
                }        
            }
        }
        return listOfFieldDetails;
    }
    
    public static List<dynlistField> traverseFieldSet(
        Schema.FieldSet fieldSetObj,
        Map<String, Schema.SObjectField> fieldDescribes,
        Set<String> setOfNonQueryableFields,
        Set<String> setOfObjFieldNameWithType,
        String objectName
    ) 
    {
        List<dynlistField> listOfFieldDetails = new List<dynlistField>();
        for (Schema.FieldSetMember fieldMember : fieldSetObj.getFields()) 
        {
            if(fieldMember.getFieldPath() != null && fieldDescribes.get(fieldMember.getFieldPath()) != null) 
            {
                Schema.DescribeFieldResult field = fieldDescribes.get(fieldMember.getFieldPath()).getDescribe();
                
                if(field.isAccessible()) 
                {
                    dynlistField fieldWrapper = dynlistFieldFactory.traverseField(field, setOfNonQueryableFields, setOfObjFieldNameWithType, objectName);
                    
                    if (!field.isUpdateable()) 
                    {
                        fieldWrapper.readOnly = true;
                    } 
                    else if (fieldMember.getRequired() || fieldMember.getDBRequired()) 
                    {
                        fieldWrapper.required = true;
                    }
                    listOfFieldDetails.add(fieldWrapper);        
                }        
            }
        }
        return listOfFieldDetails;
    }
    
    private static dynlistField traverseField(Schema.DescribeFieldResult field, Set<String> setOfNonQueryableFields, 
                                              Set<String> setOfObjFieldNameWithType, String objectName) 
    {
        dynlistField fieldWrapper = new dynlistField();
        if (String.isNotBlank(field.getName()) && !setOfNonQueryableFields.contains(field.getName().toLowerCase())) 
        {
            fieldWrapper.label = field.getLabel();
            fieldWrapper.fieldName = field.getName();
            fieldWrapper.name = field.getName();
            fieldWrapper.tooltip = field.getInlineHelpText();
            
            String fieldType = String.valueOf(field.getType());
            String ratingFieldKey = dynlistConstants.CUSTOM_TYPE_RATING + dynlistConstants.CHAR_DASH + objectName + dynlistConstants.CHAR_DASH + fieldWrapper.name.trim().toLowerCase();
            String matchingFieldKey = dynlistConstants.CUSTOM_TYPE_MATCHING + dynlistConstants.CHAR_DASH + objectName + dynlistConstants.CHAR_DASH + fieldWrapper.name.trim().toLowerCase();
            String colorFieldKey = dynlistConstants.CUSTOM_TYPE_COLOR + dynlistConstants.CHAR_DASH + objectName + dynlistConstants.CHAR_DASH + fieldWrapper.name.trim().toLowerCase();
            
            if (setOfObjFieldNameWithType.contains(matchingFieldKey)) 
            {
                fieldWrapper.type = dynlistConstants.DATA_TYPE_MATCHING;
            } 
            else if (setOfObjFieldNameWithType.contains(ratingFieldKey)) 
            {
                fieldWrapper.type = dynlistConstants.DATA_TYPE_RATING;
            } 
            else if (setOfObjFieldNameWithType.contains(colorFieldKey)) 
            {
                fieldWrapper.type = dynlistConstants.DATA_TYPE_COLOR;
            }
            else if (fieldType.equalsIgnoreCase(dynlistConstants.DATA_TYPE_COMBOBOX)
                     ||
                     fieldType.equalsIgnoreCase(dynlistConstants.DATA_TYPE_ANYTYPE)) 
            {
                fieldWrapper.type = dynlistConstants.DATA_TYPE_STRING;
            }
            else 
            {
                fieldWrapper.type = String.valueOf(field.getType());
            }
            
            if (dynlistConstants.SET_OF_DECIMAL_TYPES.contains(fieldWrapper.type)) 
            {
                fieldWrapper.scale = field.getScale();
                fieldWrapper.maximumFractionDigits = field.getScale();
            }
            
            if (!field.isNillable()) 
            {
                fieldWrapper.required = true;
            }
            
            if (field.isCalculated()) 
            {
                fieldWrapper.isCalculated = true;
            }
            
            if (!field.isUpdateable()) 
            {
                fieldWrapper.readOnly = true;
            }
            
            if (field.getType() == Schema.DisplayType.ENCRYPTEDSTRING) 
            {
                fieldWrapper.readOnly = true;
            }
            
            if (
                field.getType() == Schema.DisplayType.MULTIPICKLIST ||
                field.getType() == Schema.DisplayType.PICKLIST
            ) 
            {
                List<dynlistOption> options = new List<dynlistOption>();
                if(field.getType() == Schema.DisplayType.PICKLIST) 
                {
                    options.add(new dynlistOption(dynlistConstants.PICKLIST_OPTION_NONE_VALUE, dynlistConstants.PICKLIST_OPTION_NONE_LABEL));    
                }
                for (Schema.PicklistEntry pLE : field.getPicklistValues()) 
                {
                    if (pLE.isActive()) 
                    {
                        options.add(new dynlistOption(pLE.getValue(), pLE.getLabel()));
                    }
                }
                fieldWrapper.options = options;
            }
            
            if (field.getType() == Schema.DisplayType.REFERENCE) 
            {
                fieldWrapper.referencedObjectName = field.getReferenceTo()[0].getDescribe().getName();
                fieldWrapper.referencedObjectLabel = field.getReferenceTo()[0].getDescribe().getLabel();
                fieldWrapper.referencedObjectPluralLabel = field.getReferenceTo()[0].getDescribe().getLabelPlural();
                
                //Getting filters related details
                FilteredLookupInfo filtersInfo = field.getFilteredLookupInfo();
                if(filtersInfo != null) 
                {
                    fieldWrapper.optionalFilter = filtersInfo.optionalFilter;
                }
            }
            
            if (field.getType() == Schema.DisplayType.TEXTAREA) 
            {
                if (field.getLength() <= 255 && !field.isHtmlFormatted()) 
                {
                    fieldWrapper.type = dynlistConstants.DATA_TYPE_TEXTAREA;
                } else if (
                    (field.getLength() >= 256 && field.getLength() <= Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)) &&
                    !field.isHtmlFormatted()
                ) 
                {
                    fieldWrapper.type = dynlistConstants.DATA_TYPE_TEXTAREA;
                } else if (
                    (field.getLength() >= 256 && field.getLength() <= Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)) &&
                    field.isHtmlFormatted()
                ) 
                {
                    fieldWrapper.type = dynlistConstants.DATA_TYPE_RICHTEXTAREA;
                }
            }
            fieldWrapper.isSortable = field.isSortable();
            
        }
        return fieldWrapper;
    }
    
    public static List<dynlistField> traverseFieldForDataGrid(
        List<dynlistField> fields,
        Sobject obj,
        map<String, map<String, String>> mapOfLoopUpFieldsData,
        Integer rowNo,
        String rowRecordId,
        String objectName,
        String sortByFieldName,
        String sortByDirection,
        Set<String> setOfNonQueryableFields
    ) 
    {
        List<dynlistField> listOfFields = new List<dynlistField>();
        Integer cellNum = 1;
        
        for (dynlistField fDW : fields) 
        {
            if(String.isNotBlank(fDW.Name) && !setOfNonQueryableFields.contains(fDW.Name.toLowerCase())) 
            {
                dynlistField fld = new dynlistField();
                fld = fDW.clone();
                fld.headerLabel = fld.label;
                fld.value = obj.get(fDW.name) != null
                    ? String.valueOf(obj.get(fDW.name))
                    : dynlistConstants.CHAR_BLANK_STRING;
                fld.cellNumber = cellNum;
                fld.id = fDW.name + cellNum;
                fld.rowNumber = rowNo;
                fld.recordId = rowRecordId;
                fld.uniqueKey = rowRecordId + dynlistConstants.CHAR_DASH + fDW.name;
                
                if (fDW.type == dynlistConstants.DATA_TYPE_BOOLEAN) 
                {
                    fld.size = dynlistConstants.STYLE_CLASS_X_SMALL;
                    if (fld.value == dynlistConstants.TEXT_TRUE) {
                        fld.checked = true;
                    } else {
                        fld.checked = false;
                    }
                } else if (fDW.type == dynlistConstants.DATA_TYPE_CURRENCY) 
                {
                    fld.currencyCode = dynlistConstants.CURRENCY_CODE_USD;
                    fld.formatStyle = dynlistConstants.FORMAT_STYLE_CURRENCY;
                } else if (fDW.type == dynlistConstants.DATA_TYPE_DATE) 
                {
                    if (obj.get(fDW.name) != null)
                    {
                        String dateValue = String.valueOf(obj.get(fDW.name));
                        dateValue = dateValue.replaceAll(
                            dynlistConstants.TEXT_ZERO_ZERO_COLON_ZERO_ZERO_COLON_ZERO_ZERO,
                            dynlistConstants.CHAR_BLANK_STRING
                        );
                        dateValue = dateValue.trim();
                        fld.value = dateValue;
                        
                        fld.displayValue = obj.get(fDW.name) != null
                            ? String.valueOf(Date.valueOf(obj.get(fDW.name)).format())
                            : dynlistConstants.CHAR_BLANK_STRING;
                    }
                } else if (fDW.type == dynlistConstants.DATA_TYPE_DATETIME) 
                {
                    fld.value = obj.get(fDW.name) != null
                        ? String.valueOf(obj.get(fDW.name)).replace(dynlistConstants.CHAR_BLANK_SPACE, dynlistConstants.CHAR_T) + dynlistConstants.CHAR_Z
                        : dynlistConstants.CHAR_BLANK_STRING;
                    
                    fld.displayValue = obj.get(fDW.name) != null
                        ? String.valueOf(Datetime.valueOf(obj.get(fDW.name)).format())
                        : dynlistConstants.CHAR_BLANK_STRING;
                    
                } else if (fDW.type == dynlistConstants.DATA_TYPE_DOUBLE) 
                {
                    fld.formatStyle = dynlistConstants.FORMAT_STYLE_DECIMAL;
                } else if (fDW.type == dynlistConstants.DATA_TYPE_EMAIL) 
                {
                    fld.label = fld.value;
                } else if (fDW.type == dynlistConstants.DATA_TYPE_ENCRYPTEDSTRING) 
                {
                    if (obj.get(fDW.name) != null) 
                    {
                        fld.value = dynlistUtilities.sanitizeEncryptedData(
                            true,
                            String.valueOf(obj.get(fDW.name))
                        );
                    }
                } else if (fDW.type == dynlistConstants.DATA_TYPE_MULTIPICKLIST) 
                {
                    if (fld.value != null) 
                    {
                        List<String> values = new List<String>();
                        values = fld.value.split(dynlistConstants.CHAR_SEMI_COLON);
                        if (values.size() > 0) {
                            fld.values = values;
                        } else {
                            fld.values = new List<String>();
                        }
                    }
                } else if (fDW.type == dynlistConstants.DATA_TYPE_PERCENT) 
                {
                    fld.formatStyle = dynlistConstants.FORMAT_STYLE_PERCENT;
                } else if (fDW.type == dynlistConstants.DATA_TYPE_REFERENCE) 
                {
                    if (String.isNotBlank(String.valueOf(obj.get(fDW.name)))) 
                    {
                        Id recordId = String.valueOf(obj.get(fDW.name));
                        String sObjName = recordId.getSObjectType().getDescribe().getName();
                        if (fDW.name == dynlistConstants.RECORD_TYPE_ID_FIELD_NAME) 
                        {
                            fld.lookupData = new dynlistLookup(
                                String.valueOf(obj.get(fDW.name)),
                                mapOfLoopUpFieldsData.get(sObjName)
                                .get(String.valueOf(obj.get(fDW.name))),
                                dynlistConstants.RECORD_TYPE_ID_FIELD_NAME,
                                objectName
                            );
                        } else 
                        {
                            fld.lookupData = new dynlistLookup(
                                String.valueOf(obj.get(fDW.name)),
                                mapOfLoopUpFieldsData.get(sObjName)
                                .get(String.valueOf(obj.get(fDW.name)))
                            );
                        }
                        fld.value = obj.get(fDW.name) != null
                            ? String.valueOf(obj.get(fDW.name))
                            : dynlistConstants.CHAR_BLANK_STRING;
                        fld.referenceFieldValue = mapOfLoopUpFieldsData.get(sObjName).get(String.valueOf(obj.get(fDW.name)));    
                    } else 
                    {
                        fld.lookupData = new dynlistLookup(null, null);
                        fld.value = null;
                        fld.referenceFieldValue = null;
                    }
                    
                    if (
                        String.isNotBlank(fDW.label) &&
                        fDW.label.endsWith(dynlistConstants.DATA_TYPE_ID)
                    ) 
                    {
                        fDW.label = fDW.label.removeEnd(dynlistConstants.DATA_TYPE_ID);
                        fDW.label = fDW.label.trim();
                        fld.label = fDW.label;
                        fld.headerLabel = fDW.label;
                    }
                } else if (fDW.type == dynlistConstants.DATA_TYPE_STRING) 
                {
                    if (fDW.name == dynlistConstants.NAME_FIELD_NAME) 
                    {
                        fld.lookupData = new dynlistLookup(
                            rowRecordId,
                            String.valueOf(obj.get(fDW.name))
                        );
                        fld.value = obj.get(fDW.name) != null
                            ? String.valueOf(obj.get(fDW.name))
                            : dynlistConstants.CHAR_BLANK_STRING;
                        fld.isNameField = true;
                        fld.required = true;
                    }
                    fld.title = fld.value.replaceAll(
                        dynlistConstants.REGEX_RICH_TEXT_AREA,
                        dynlistConstants.CHAR_BLANK_STRING
                    );
                } else if (fDW.type == dynlistConstants.DATA_TYPE_RICHTEXTAREA) 
                {
                    if (fld.value != null) 
                    {
                        fld.title = fld.value.replaceAll(
                            dynlistConstants.REGEX_RICH_TEXT_AREA,
                            dynlistConstants.CHAR_BLANK_STRING
                        );
                    }
                } else if (fDW.type == dynlistConstants.DATA_TYPE_TIME) 
                {
                    fld.value = obj.get(fDW.name) != null
                        ? String.valueOf(obj.get(fDW.name))
                        : dynlistConstants.CHAR_BLANK_STRING;
                    
                    if (
                        fld.value != null &&
                        fld.value.contains(dynlistConstants.CHAR_FULL_STOP) &&
                        fld.value.split(dynlistConstants.CHAR_ESCAPE_DOT).size() > 0
                    ) 
                    {
                        List<String> getTimeFromStr = fld.value.split(dynlistConstants.CHAR_ESCAPE_DOT)[0].split(dynlistConstants.CHAR_COLON);
                        Integer timeHourDiff = Integer.valueOf(getTimeFromStr[0]) - 12;
                        String displayHours = 0 < timeHourDiff ? timeHourDiff < 10 ? dynlistConstants.CHAR_ZERO + timeHourDiff : String.valueOf(timeHourDiff) : -12 == timeHourDiff ? dynlistConstants.CHAR_TWELVE : getTimeFromStr[0];
                        String displayMins = 10 > Integer.valueOf(getTimeFromStr[1]) ? dynlistConstants.CHAR_ZERO +Integer.valueOf(getTimeFromStr[1]) : getTimeFromStr[1];
                        String displaySeconds = 10 > Integer.valueOf(getTimeFromStr[2]) ? dynlistConstants.CHAR_ZERO + Integer.valueOf(getTimeFromStr[2]) : getTimeFromStr[2];
                        fld.title = displayHours + dynlistConstants.CHAR_COLON + displayMins + dynlistConstants.CHAR_COLON + displaySeconds + dynlistConstants.CHAR_BLANK_SPACE + (0 > timeHourDiff ? dynlistConstants.CHAR_AM : dynlistConstants.CHAR_PM);       
                    	fld.displayValue = fld.title;
                    } else 
                    {
                        fld.title = fld.value;
                    }
                } else if (fDW.type == dynlistConstants.DATA_TYPE_COLOR) 
                {
                    if (fld.value != null) 
                    {
                        fld.styleClass = dynlistConstants.CHAR_CSS_BACKGROUND_COLOR + fld.value + dynlistConstants.CHAR_SEMI_COLON;
                    }    
                }
                
                if (dynlistConstants.SET_OF_DECIMAL_TYPES.contains(fld.type)) 
                {
                    try
                    {
                        fld.value = String.isNotBlank(fld.value)
                            ? String.valueOf((Decimal.valueOf(fld.value).setScale(fld.scale)))
                            : null;
                        fld.title = String.isNotBlank(fld.value)
                            ? String.valueOf((Decimal.valueOf(fld.value).setScale(fld.scale)))
                            : null;
                    }
                    catch (exception e)
                    {
                        fld.value = String.isNotBlank(fld.value)
                            ? String.valueOf((Integer.valueOf(fld.value)))
                            : null;
                        fld.title = String.isNotBlank(fld.value)
                            ? String.valueOf((Integer.valueOf(fld.value)))
                            : null;
                    } 
                }
                
                fld.fieldCellStyleClass = fDW.type;
                
                //Handling of Synonym Fields that are being on objects that doesn't have standard name field
                if(String.isNotBlank(objectName) 
                   && mapOfObjectsNotHavingNameField != null 
                   && mapOfObjectsNotHavingNameField.get(objectName.toLowerCase()) != null
                  ) 
                {
                    if(String.isNotBlank(mapOfObjectsNotHavingNameField.get(objectName.toLowerCase()).Synonym_Field_API_Name__c)
                       && mapOfObjectsNotHavingNameField.get(objectName.toLowerCase()).Synonym_Field_API_Name__c.equalsIgnoreCase(fDW.name)
                      ) 
                    {
                        fld.Type = dynlistConstants.DATA_TYPE_HYPERLINK;
                        fld.hyperlinkLabel = fld.value;
                        fld.hyperlinkTitle = fld.value;
                        fld.hyperlinkURL = dynlistUtilities.DYNLIST_ORG_HOST_URL + fld.recordId;
                    }
                    
                    //Doing additional handling for the history objects
                    if(mapOfObjectsNotHavingNameField.get(objectName.toLowerCase()).History_Tracking_Object__c) 
                    {
                        if(String.isNotBlank(dynlistFieldFactory.parentFieldNameSettedInConfiguration))
                        {
                            Schema.DescribeFieldResult fieldDescribeResult = dynlistUtilities.getFieldDescribeResult(
                                dynlistUtilities.getObjectTypeOnBasisOfObjectName(objectName), dynlistFieldFactory.parentFieldNameSettedInConfiguration);
                            if(fieldDescribeResult != null) 
                            {
                                if(fieldDescribeResult.getReferenceTo() != null && fieldDescribeResult.getReferenceTo().size() > 0) 
                                {
                                    if(fieldDescribeResult.getReferenceTo()[0].getDescribe() != null) 
                                    {
                                        if(String.isNotBlank(fld.Name) && fld.Name.equalsIgnoreCase(dynlistConstants.HISTORY_OBJECT_FIELD_FIELD_API_NAME)) 
                                        {
                                            //Getting details for field that is being there in fld.value
                                            Schema.DescribeFieldResult parentFieldDescribeResult = dynlistUtilities.getFieldDescribeResult(
                                                dynlistUtilities.getObjectTypeOnBasisOfObjectName(fieldDescribeResult.getReferenceTo()[0].getDescribe().getName()),
                                                fld.value
                                            );
                                            
                                            if(parentFieldDescribeResult != null) 
                                            {
                                                fld.value = parentFieldDescribeResult.getLabel();
                                                
                                                //Logic to skip ID value rows for reference type fields
                                                if(parentFieldDescribeResult.getType() == Schema.DisplayType.REFERENCE) 
                                                {
                                                    fld.fieldHistoryForReferenceField = true;
                                                }
                                            }
                                            
                                            if(String.isNotBlank(mapOfObjectsNotHavingNameField.get(objectName.toLowerCase()).History_Tracking_Special_Fields_Details__c)) 
                                            {
                                                String historySpecialFieldsDetails = mapOfObjectsNotHavingNameField.get(objectName.toLowerCase()).History_Tracking_Special_Fields_Details__c;
                                                if(historySpecialFieldsDetails.split(dynlistConstants.CHAR_COMMA).size() > 1) 
                                                {
                                                    for(String fldNameString : historySpecialFieldsDetails.split(dynlistConstants.CHAR_COMMA)) 
                                                    {
                                                        if(fldNameString.split(dynlistConstants.CHAR_ARROW).size() > 1) 
                                                        {
                                                            String fldAPIName = fldNameString.split(dynlistConstants.CHAR_ARROW)[0];
                                                            String fldLabel = fldNameString.split(dynlistConstants.CHAR_ARROW)[1];
                                                            if(String.isNotBlank(fldAPIName) && fldAPIName.equalsIgnoreCase(fld.Value)) 
                                                            {
                                                                fld.value = fldLabel;
                                                            }
                                                        }
                                                    }    
                                                }
                                                else 
                                                {
                                                    if(historySpecialFieldsDetails.split(dynlistConstants.CHAR_ARROW).size() > 1) 
                                                    {
                                                        String fAPIName = historySpecialFieldsDetails.split(dynlistConstants.CHAR_ARROW)[0];
                                                        String fLabel = historySpecialFieldsDetails.split(dynlistConstants.CHAR_ARROW)[1];
                                                        if(String.isNotBlank(fAPIName) && fAPIName.equalsIgnoreCase(fld.Value)) 
                                                        {
                                                            fld.value = fLabel;
                                                        }
                                                    }        
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }    
                    }
                }
                
                if (fDW.type == dynlistConstants.DATA_TYPE_INTEGER)
                {
                    fld.type = dynlistConstants.DATA_TYPE_DOUBLE;
                    fld.formatStyle = dynlistConstants.FORMAT_STYLE_DECIMAL;
                }
                
                if(String.isNotBlank(fDW.fieldName) && fDW.fieldName.equalsIgnoreCase(sortByFieldName)) 
                {
                    if(String.isNotBlank(sortByDirection)) 
                    {
                        String sortByDirectionLowerCase = sortByDirection.trim().toLowerCase();
                        if(sortByDirectionLowerCase == dynlistConstants.CHAR_ASC_LOWERCASE) 
                        {
                            fld.displaySortingIcon = true;
                            fld.displayArrowUpIcon = true;
                            fld.displayArrowDownIcon = false; 
                        }
                        else if(sortByDirectionLowerCase == dynlistConstants.CHAR_DESC_LOWERCASE) 
                        {
                            fld.displaySortingIcon = true;
                            fld.displayArrowUpIcon = false;
                            fld.displayArrowDownIcon = true;  
                        }
                        else 
                        {
                            fld.displaySortingIcon = false;
                            fld.displayArrowUpIcon = false;
                            fld.displayArrowDownIcon = false; 
                        }
                    }
                    else 
                    {
                        fld.displaySortingIcon = false;
                        fld.displayArrowUpIcon = false;
                        fld.displayArrowDownIcon = false;    
                    }
                }
                else 
                {
                    fld.displaySortingIcon = false;
                    fld.displayArrowUpIcon = false;
                    fld.displayArrowDownIcon = false;   
                }
                
                listOfFields.add(fld);
                cellNum++;        
            }
        }
        return listOfFields;
    }
}