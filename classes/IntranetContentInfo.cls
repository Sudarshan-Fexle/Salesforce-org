public virtual class IntranetContentInfo implements Comparable {

    public Integer RowNumber {get; set;}
    public String Id {get; set;}
    public String ItemTitle {get; set;}
    public String ItemType {get; set;}
    public String Permalink {get; set;}
    public Intranet_Container__c topParentContainer { get; set; }
    public String ScheduleReferenceNumber { get; set; }

    public Decimal ChatterLikes {get; set;}
    public Decimal ChatterComments {get; set;}
    //public Decimal ChatterShares {get; set;}

    public String SortOrder {get; set;}
    public Double SortOrderNumber {get; set;}
    public Boolean SortAscendingly { get; set; }

    public List<FieldInfo> Properties { get; set; }

    public string Topics {get; set;}

    public IntranetContentInfo() {

    }
    public IntranetContentInfo(Intranet_Item__c item, Intranet_Schedule__c schedule, Intranet_Container__c container, Schema.FieldSet fieldset,
                               Map<String, Schema.SObjectField> fieldMap, SObjectField sortField, boolean ascending) {

        Id = item.Id;
        ItemTitle = item.Item_Title__c;
        ItemType = item.Item_Type__c;
        ChatterLikes = item.Chatter_Likes__c;
        ChatterComments = item.Chatter_Comments_Rollup__c;
        //EventStartDateTime = item.Event_Start_Date_Time__c;
        //ChatterShares = item.Chatter_Shares__c;
        topParentContainer = container;
        if (schedule != null) ScheduleReferenceNumber = schedule.Intranet_Container__r.Reference_Number__c;

        Permalink = item.Permalink_Validated__c;

        Intranet_Defaults__c intranetDefault;
        if(!String.isBlank(item.Event_Type__c))
            intranetDefault = IntranetHomeUtility.LookupIntranetDefaultByName(item.Event_Type__c);
        if(intranetDefault == null)
            intranetDefault = IntranetHomeUtility.LookupIntranetDefault(itemType);
        if (intranetDefault != null && intranetDefault.SearchCategory__c != 'Exclude' && intranetDefault.ContentViewerView__c != null) {
            if(intranetDefault.ContentViewerView__c == 'Page' && ItemType == 'Page Section') {
                if(schedule != null && schedule.Intranet_Container__r.Top_Parent_Container_Id__c != null) {
                    Permalink = '/apex/Boardroom_Internal_Home_Page?TopContainerId=' + schedule.Intranet_Container__r.Top_Parent_Container_Id__c;
                    if (ScheduleReferenceNumber != null)
                        Permalink = Permalink + '#' + ScheduleReferenceNumber;
                }
                
            } else if(Permalink == null) {
                if(intranetDefault.ContentViewerView__c == 'Link_URL__c') {
                    Permalink = item.Link_URL_Validated__c;

                } else if (intranetDefault.ContentViewerView__c.contains('mode=calendar')) {
                    Permalink = '/apex/IntranetContentViewer?' + intranetDefault.ContentViewerView__c + '&SearchContentId=' +  Id + '&SearchContentType=' +
                        ItemType + '&SearchStartDate=' + EncodingUtil.urlEncode(item.Event_Start_Date_Time__c.format('MM/dd/yyyy'), 'UTF-8');

                } else {
                    Permalink = '/apex/IntranetContentViewer?' + intranetDefault.ContentViewerView__c +
                                '&SearchContentId=' +  Id + '&SearchContentType=' +  ItemType;

                }
            }
        }

        SortAscendingly = ascending == null ? true : ascending;
        if (sortField != null) {
            String sortType = sortField.getDescribe().getType().name();
            object o = item.get(sortField);
            if (o == null) {
                SortOrder = '';
            } else {
                if (sortType == 'DOUBLE') {
                    SortOrderNumber = (o != null) ? double.valueOf(o) : 0;
                } else if (sortType == 'DATE' || sortType == 'DATETIME') {
                    SortOrderNumber = (o != null) ? Datetime.valueOf(o).getTime() : 0;
                } else {
                    SortOrder = (o != null) ? string.valueOf(o) : '';
                }
            }
        } else {
            SortOrder = '';
        }

        Properties = new List<FieldInfo>();

        // Add Page Name for the page search
        if (ItemType == 'Page Section') {
            Properties.add(new FieldInfo('Page', 'STRING', container==null? '' : container.Display_Name__c));
        }

        if (fieldset != null) {
            boolean firstChatter = true;
            for (Schema.FieldSetMember member : fieldset.getFields()) {
                Schema.SObjectField field = fieldMap.get(member.FieldPath);
                DescribeFieldResult fieldDescriber = field.getDescribe();
                Object itemValue = item.get(field);

                if (member.FieldPath == 'Chatter_Likes__c' || member.FieldPath == 'Chatter_Comments_Rollup__c') {
                    if (firstChatter) {
                        firstChatter = false;
                        Properties.add(new FieldInfo('Social',
                                                     'STRING',
                                                     ChatterLikes + ',' + ChatterComments));
                    }
                    continue;
                }

                if (member.FieldPath == 'Event_Start_Date_Time__c') {
                    Datetime myDatetime = item.Event_Start_Date_Time__c;
                    //String newDate = myDatetime == null ? '' : myDatetime.format('M/d/yyyy h:mm a', 'America/New_York');
                    String newDate = (myDatetime == null ? '' : (String.valueOf(myDatetime.month()) + '/' + String.valueOf(myDatetime.day()) + '/' + String.valueOf(myDatetime.year())));
                    
                    Properties.add(new FieldInfo('Event Date',
                                                 'STRING',
                                                 newDate));
                    continue;
                }

                // Pull in Office_Name__c from schedule
                if (member.FieldPath == 'Office_Name__c') {
                    String officeName = item.Office_Name__c;
                    if (schedule != null && schedule.Office__c != null) {
                        officeName = IntranetHomeUtility.LookupOfficeNameById(schedule.Office__c);
                    }
                    if (officeName == null) officeName = '';

                    Properties.add(new FieldInfo('Office',
                                                 'STRING',
                                                 officeName));
                    continue;
                }

                if (member.FieldPath == 'Item_Title__c') {
                    Properties.add(new FieldInfo('Title',
                                                 fieldDescriber.getType().name(),
                                                 itemValue == null ? '' : string.valueOf(itemValue)));
                    continue;
                }

                if (member.FieldPath == 'Item_Type__c') {
                    Properties.add(new FieldInfo('Item',
                                                 fieldDescriber.getType().name(),
                                                 itemValue == null ? '' : string.valueOf(itemValue)));
                    continue;
                }
                
                if(member.FieldPath == 'Content_Publish_Date__c') {
                    DateTime myDatetime = item.Content_Publish_Date__c;
                    String newDate = (myDatetime == null ? '' : (String.valueOf(myDatetime.month()) + '/' + String.valueOf(myDatetime.day()) + '/' + String.valueOf(myDatetime.year())));
                    
                    Properties.add(new FieldInfo('Publish Date',
                                                 fieldDescriber.getType().name(),
                                                 itemValue == null ? '' : newDate));
                    continue;
                }
				
                Properties.add(new FieldInfo(fieldDescriber.getLabel(),
                                             fieldDescriber.getType().name(),
                                             itemValue == null ? '' : string.valueOf(itemValue)));
            }
        }

        List<String> topics = new List<String>();
        ConnectApi.TopicPage page = ConnectApi.Topics.getTopics('Internal', Id);
        for (ConnectApi.Topic t : page.topics) {
            topics.add(t.Name);
        }
        this.Topics = string.join(topics, ', ');
        if (this.Topics == null || this.Topics == '') this.Topics = ' ';
    }

    public Integer compareTo(Object compareTo) {
        if (compareTo == null) return SortAscendingly ? 1 : -1;
        IntranetContentInfo compareToIContent = (IntranetContentInfo)compareTo;
        if (compareToIContent == null) return SortAscendingly ? 1 : -1;

        if (SortOrder == null) {
            if ( SortOrderNumber == compareToIContent.SortOrderNumber ) return 0;
            if ( SortOrderNumber > compareToIContent.SortOrderNumber ) return SortAscendingly ? 1 : -1;
            return SortAscendingly ? -1 : 1;
        } else {
            if ( SortOrder == compareToIContent.SortOrder ) return 0;
            if ( SortOrder > compareToIContent.SortOrder ) return SortAscendingly ? 1 : -1;
            return SortAscendingly ? -1 : 1;
        }
    }

    public string ToString(string indent) {
        return indent + 'ContentInfo: (Id=' + this.Id + ' title=' + this.ItemTitle + ', type=' + this.ItemType + ', sortOrder=' + this.sortOrder + ')<br>';
    }

    public IntranetContentInfo DuplicateToHeader() {
        IntranetContentInfo header = new IntranetContentInfo();
        header.Properties = new List<FieldInfo>();
        for (FieldInfo fi : this.Properties) {
            header.Properties.add(new FieldInfo(fi.FieldLabel, fi.FieldType, fi.FieldLabel));
        }
        return header;
    }

    public class FieldInfo {
        public string FieldLabel { get; private set;}
        public string FieldType { get; private set; }
        public string FieldValue { get; private set; }

        public FieldInfo(string flabel, string ftype, string fvalue) {
            this.FieldLabel = flabel;
            this.FieldType = ftype;
            this.FieldValue = fvalue;

        }
    }
}