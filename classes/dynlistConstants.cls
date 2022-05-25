/*
Purpose         :   Dynamic Related List Constants
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
@SuppressWarnings('PMD.UnusedLocalVariable')
public without sharing class dynlistConstants 
{    
    public static final String SUCCESS = 'success';
    public static final String WARNING = 'warning';
    public static final String ERROR = 'error';
    public static final String ERROR_WITH_COLON = 'error:';
    
    public static final String ERROR_TYPE_FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    
    public static final String ID_FIELD_API_NAME = 'id';
    public static final String ID_FIELD_NAME = 'Id';
    public static final String NAME_FIELD_NAME = 'Name';
    public static final String NAME_FIELD_NAME_LOWERCASE = 'name';
    
    public static final String RECORD_TYPE_ID_FIELD_NAME = 'RecordTypeId';
    public static final String RECORD_TYPE_API_NAME = 'Recordtype';
    
    public static final String SOQL_STRING_REQUIRED_PREFIX = 'select ';
    public static final String SOQL_SELECT_KEYWORD_WITH_COMMA = 'select ,';
    public static final String SOQL_STRING_FROM_KEYWORD = ' from ';
    public static final String SOQL_STRING_WITH_SECURITY_ENFORCED_KEYWORD = 'WITH SECURITY_ENFORCED';
    
    public static final String CHAR_DOUBLE_UNDERSCORE_C = '__c';
    public static final String CHAR_DOUBLE_UNDERSCORE_R = '__r';
    public static final String CHAR_COMMA = ',';
    public static final String CHAR_FULL_STOP = '.';
    public static final String CHAR_BLANK_SPACE = ' ';
    public static final String CHAR_BLANK_STRING = '';
    public static final String CHAR_COLON = ':';
    public static final String CHAR_DOLLOR = '$';
    public static final String CHAR_DOLLOR_SOURCE = '$Source';
    public static final String CHAR_DOLLOR_USER = '$User';
    public static final String CHAR_DOLLOR_USER_ROLE = '$UserRole';
    public static final String CHAR_DOLLOR_PROFILE = '$Profile';
    public static final String CHAR_ARROW = '-->';
    public static final String CHAR_NULL = 'null';
    
    public static final String CHAR_USER_ROLE_LOWERCASE = 'userrole';
    public static final String CHAR_USER_LOWERCASE = 'user';
    public static final String CHAR_PROFILE_LOWERCASE = 'profile';
    public static final String CHAR_MANAGE_USERS_LOWERCASE = 'manageusers';
    public static final String CHAR_PERMISSIONS_MANAGE_USERS_LOWERCASE = 'permissionsmanageusers';
    
    public static final String CHAR_USER_ROLE = 'UserRole';
    public static final String CHAR_USER = 'User';
    public static final String CHAR_PROFILE = 'Profile';
    public static final String CHAR_NULL_LOWERCASE = 'null';
    
    public static final String CHAR_EQUALS = 'equals';
    public static final String CHAR_NOT_EQUALS = 'notEqual';
    public static final String CHAR_GREATER_THAN = 'greaterThan';
    public static final String CHAR_LESS_THAN = 'lessThan';
    public static final String CHAR_CONTAINS = 'contains';
    public static final String CHAR_STARTS_WITH = 'startsWith';
    public static final String CHAR_GREATER_OR_EQUAL = 'greaterOrEqual';
    public static final String CHAR_NOT_CONTAIN = 'notContain';
    public static final String CHAR_LESS_OR_EQUAL = 'lessOrEqual';
    
    public static final String CHAR_SEMI_COLON = ';';
    public static final String CHAR_T = 'T';
    public static final String CHAR_Z = 'Z';
    public static final String CHAR_SMALL_Z = 'z';
    public static final String CHAR_X = 'X';
    public static final String CHAR_DASH = '-';
    public static final String CHAR_BACK_SLASH = '/';
    public static final String CHAR_WHERE = 'WHERE';
    public static final String CHAR_AND = 'AND';
    public static final String CHAR_OR = 'OR';
    public static final String CHAR_SELECT = 'SELECT';
    public static final String CHAR_FROM = 'FROM';
    public static final String CHAR_EQUAL = '=';
    public static final String CHAR_ORDER_BY = 'ORDER BY';
    public static final String CHAR_LIMIT = 'LIMIT';
    public static final String CHAR_OFFSET = 'OFFSET';
    public static final String CHAR_NEW_LINE = '\n';
    public static final String CHAR_ZERO = '0';
    public static final String CHAR_ONE = '1';
    public static final String CHAR_TEN = '10';
    public static final String CHAR_TWELVE = '12';
    public static final String CHAR_TWENTY_FIVE = '25';
    public static final String CHAR_TWENTY_FOUR = '24';
    public static final String CHAR_DOUBLE_QUOTE = '"';
    public static final String CHAR_ESCAPE_DOT = '\\.';
    public static final String CHAR_SCHEMA = 'Schema';
    public static final String CHAR_HIDDEN = 'Hidden';
    public static final String CHAR_ZERO_ZERO_TIME_STRING = '00:00:00';
    public static final String CHAR_QUERY_STRING_LITERAL = 'query/?q=';
    
    public static final String CHAR_CSS_BACKGROUND_COLOR = 'background-color: ';
    public static final String REGEX_RICH_TEXT_AREA = '<[^>]*>';
    public static final String REGEX_LOOKYP_FILTERS = ' {J} ';
    
    public static final String CHAR_AUTHORIZATION = 'Authorization';
    public static final String CHAR_BEARER = 'Bearer';
    public static final String CHAR_CONTENT_TYPE = 'Content-Type';
    public static final String CHAR_APPLICATION_JSON = 'application/json';
    
    public static final String CHAR_ASC = 'ASC';
    public static final String CHAR_ASC_LOWERCASE = 'asc';
    public static final String CHAR_DESC = 'DESC';
    public static final String CHAR_DESC_LOWERCASE = 'desc';
    
    public static final String CHAR_NULLS_LAST = 'NULLS LAST';
    public static final String CHAR_NULLS_FIRST = 'NULLS FIRST';
    
    public static final String OBJECT_NAME_OPPORTUNITY = 'Opportunity';
    public static final String OBJECT_NAME_ACCOUNT = 'Account';
    public static final String OBJECT_NAME_CONTRACT = 'Contract';
    public static final String OBJECT_NAME_CONTACT = 'Contact';
    public static final String OBJECT_NAME_CASE = 'Case';
    public static final String OBJECT_NAME_OPPORTUNITY_HISTORY = 'OpportunityHistory';
    public static final String OBJECT_NAME_ACCOUNT_HISTORY = 'AccountHistory';
    
    public static final String OBJECT_NAME_CASE_FIELD_CASE_NUMBER = 'Casenumber';
    
    public static final String CHAR_AM = 'AM';
    public static final String CHAR_PM = 'PM';
    
    public static final String CHAR_HTTPS = 'https://';
    public static final String HTTP_GET_METHOD = 'GET';
    public static final String HTTP_POST_METHOD = 'POST';
    public static final String HTTP_PUT_METHOD = 'PUT';
    
    public static final Integer HTTP_CALLOUT_SUCCESS_STATUS_CODE = 200;
    public static final Integer HTTP_CALLOUT_STATUS_CODE_300 = 300;
    public static final Integer HTTP_MAX_TIMEOUT_VALUE = 120000;
    
    public static final String FIELD_TYPE_REFERENCE = 'Reference';
    public static final String FIELD_TYPE_BOOLEAN = 'Boolean';
    
    public static final String EXCEPTION_SUFFIX = '!! Exception: ';
    public static final String SECURE_QUERY = 'secure query ';
    public static final String VARIENT_LABEL_HIDDEN = 'label-hidden';
    public static final String TARGET_BLANK = '_blank';
    public static final String TEXT_AVAILABLE = 'Available';
    public static final String TEXT_SELECTED = 'Selected';
    public static final String TEXT_TRUE = 'true';
    public static final String TEXT_ZERO_ZERO_COLON_ZERO_ZERO_COLON_ZERO_ZERO = '00:00:00';
    public static final String TEXT_RECORD_TYPES_WITH_BACK_SLASHES = '/RecordTypes/';
    public static final String TEXT_VIEW_WITH_BACK_SLASH = '/view';
    
    public static final String STYLE_CLASS_X_SMALL = 'x-small';
    
    public static final String CURRENCY_CODE_USD = 'USD';
    
    public static final String FORMAT_STYLE_CURRENCY = 'currency';
    public static final String FORMAT_STYLE_DECIMAL = 'decimal';
    public static final String FORMAT_STYLE_PERCENT = 'percent';
    
    public static final String VIEW_TYPE_TABLE = 'table';
    public static final String VIEW_TYPE_TILE = 'tile';
    public static final String VIEW_TYPE_TILES = 'tiles';
    public static final String VIEW_TYPE_KANBAN = 'kanban';
    public static final String VIEW_TYPE_TABLE_LABEL = 'Table';
    public static final String VIEW_TYPE_TILE_LABEL = 'Tile';
    public static final String VIEW_TYPE_KANBAN_LABEL = 'Kanban';
    
    public static final String DATA_TYPE_ADDRESS = 'ADDRESS';
    public static final String DATA_TYPE_ANYTYPE = 'ANYTYPE';
    public static final String DATA_TYPE_BASE64 = 'BASE64';
    public static final String DATA_TYPE_BOOLEAN = 'BOOLEAN';
    public static final String DATA_TYPE_COLOR = 'COLOR';
    public static final String DATA_TYPE_COMBOBOX = 'COMBOBOX';
    public static final String DATA_TYPE_COMPLEXVALUE = 'COMPLEXVALUE';
    public static final String DATA_TYPE_CURRENCY = 'CURRENCY';
    public static final String DATA_TYPE_DATACATEGORYGROUPREFERENCE = 'DATACATEGORYGROUPREFERENCE';
    public static final String DATA_TYPE_DATE = 'DATE';
    public static final String DATA_TYPE_DATETIME = 'DATETIME';
    public static final String DATA_TYPE_DECIMAL = 'DECIMAL';
    public static final String DATA_TYPE_DOUBLE = 'DOUBLE';
    public static final String DATA_TYPE_EMAIL = 'EMAIL';
    public static final String DATA_TYPE_ENCRYPTEDSTRING = 'ENCRYPTEDSTRING';
    public static final String DATA_TYPE_ID = 'ID';
    public static final String DATA_TYPE_INTEGER = 'INTEGER';
    public static final String DATA_TYPE_JSON = 'JSON';
    public static final String DATA_TYPE_LOCATION = 'LOCATION';
    public static final String DATA_TYPE_LONG = 'LONG';
    public static final String DATA_TYPE_MATCHING = 'MATCHING';
    public static final String DATA_TYPE_MULTIPICKLIST = 'MULTIPICKLIST';
    public static final String DATA_TYPE_PERCENT = 'PERCENT';
    public static final String DATA_TYPE_PHONE = 'PHONE';
    public static final String DATA_TYPE_PICKLIST = 'PICKLIST';
    public static final String DATA_TYPE_RATING = 'RATING';
    public static final String DATA_TYPE_REFERENCE = 'REFERENCE';
    public static final String DATA_TYPE_SOBJECT = 'SOBJECT';
    public static final String DATA_TYPE_STRING = 'STRING';
    public static final String DATA_TYPE_TEXTAREA = 'TEXTAREA';
    public static final String DATA_TYPE_RICHTEXTAREA = 'RICHTEXTAREA';
    public static final String DATA_TYPE_TIME = 'TIME';
    public static final String DATA_TYPE_HYPERLINK = 'HYPERLINK';
    public static final String DATA_TYPE_SIGNATURE = 'SIGNATURE';
    
    public static final String PICKLIST_OPTION_NONE_LABEL = '--None--';
    public static final String PICKLIST_OPTION_NONE_VALUE = '';
    
    public static final Set<String> SET_OF_SPECIAL_REFERENCE_FIELDS = new Set<String>{'jigsawcontactid'};
    public static final Set<String> SET_OF_DECIMAL_TYPES = new Set<String>{'DOUBLE','CURRENCY','PERCENT'};
            
    public static final String DATA_GRID_REQUEST_PARAM_VIEW = 'view';
    public static final String DATA_GRID_REQUEST_PARAM_PAGE_SIZE = 'pagesize';
    public static final String DATA_GRID_REQUEST_PARAM_OBJECT_NAME = 'objectname';
    public static final String DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME = 'fieldsetname';
    public static final String DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE = 'whereclause';
    public static final String DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME = 'groupbyfieldname';
    public static final String DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME = 'summarizebyfieldname';
    public static final String DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME = 'selectfieldsname';
    public static final String DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME = 'defaultsortfieldname';
    public static final String DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION = 'defaultsortdirection';
    public static final String DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST = 'nullsfirstorlast';
    public static final String DATA_GRID_REQUEST_PARAM_LIMIT_STRING = 'limitstring';
    public static final String DATA_GRID_REQUEST_PARAM_OFFSET_STRING = 'offsetstring';
    public static final String DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID = 'currentcontextrecordid';
    public static final String DATA_GRID_REQUEST_PARAM_SEARCH_BY = 'searchby';
    public static final String DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_PARENT_FIELD_NAME = 'currentcontextparentfieldname';
    public static final String DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE = 'enforceWithSecurityMode';
    public static final String IS_COLUMNS_AND_FILTERS_SECTION_NEEDED = 'isColumnsAndFiltersSectionNeeded';
    public static final String RECORD_PAGE_PARENT_FIELD_API_NAME = 'recordPageParentFieldAPIName';
    public static final String RECORD_PAGE_PARENT_OBJECT_API_NAME = 'recordPageParentObjectAPIName';
    public static final String RECORD_PAGE_PARENT_TO_PARENT_FIELD_MAPPING = 'recordPageParentToParentFieldNameMappings';
    public static final String IS_SYSTEM_MODE = 'isSystemMode';
    
    //For ctrlFilters
    //Start from here
    public static final Map<String, List<Schema.DisplayType>> validTypesFor;
    public static final List<Schema.DisplayType> STRING_TYPES = new List<Schema.DisplayType>
    {
        Schema.DisplayType.base64,
            Schema.DisplayType.MultiPicklist,
            Schema.DisplayType.Phone,
            Schema.DisplayType.Picklist,
            Schema.DisplayType.String,
            Schema.DisplayType.TextArea,
            Schema.DisplayType.URL
            };
                
                public static final List<Schema.DisplayType> NON_STRING_TYPES = new List<Schema.DisplayType>
            {
                Schema.DisplayType.ID,
                    Schema.DisplayType.Reference,
                    Schema.DisplayType.Email,
                    Schema.DisplayType.Boolean,
                    Schema.DisplayType.Combobox
                    };
                        
                        public static final List<Schema.DisplayType> NUMBER_TYPES = new List<Schema.DisplayType>
                    {
                        Schema.DisplayType.Integer,
                            Schema.DisplayType.Currency,
                            Schema.DisplayType.Double,
                            Schema.DisplayType.Percent,
                            Schema.DisplayType.DateTime,
                            Schema.DisplayType.Date
                            };
                                
                                public static final List<Schema.DisplayType> QUOTE_TYPES = new List<Schema.DisplayType>
                            {
                                Schema.DisplayType.ID,
                                    Schema.DisplayType.Reference,
                                    Schema.DisplayType.base64,
                                    Schema.DisplayType.Email,
                                    Schema.DisplayType.MultiPicklist,
                                    Schema.DisplayType.Phone,
                                    Schema.DisplayType.Picklist,
                                    Schema.DisplayType.String,
                                    Schema.DisplayType.TextArea,
                                    Schema.DisplayType.URL,
                                    Schema.DisplayType.Combobox
                                    };
                                        
                                        public static final Map<String, String> operatorTemplates;
    
    static 
    {
        operatorTemplates = new Map<String, String>();
        validTypesFor = new Map<String, List<Schema.DisplayType>>();
        
        List<Schema.DisplayType> ALL_TYPES = new List<Schema.DisplayType>();
        ALL_TYPES.addAll(STRING_TYPES);
        ALL_TYPES.addAll(NON_STRING_TYPES);
        ALL_TYPES.addAll(NUMBER_TYPES);
        
        validTypesFor.put('equals', ALL_TYPES);
        operatorTemplates.put('equals', 'O1 = O2');
        
        validTypesFor.put('not equals', ALL_TYPES);
        operatorTemplates.put('not equals', 'O1 <> O2');
        
        validTypesFor.put('greater than', NUMBER_TYPES);
        operatorTemplates.put('greater than', 'O1 > O2');
        
        validTypesFor.put('less than', NUMBER_TYPES);
        operatorTemplates.put('less than', 'O1 < O2');
        
        validTypesFor.put('greater or equal', NUMBER_TYPES);
        operatorTemplates.put('greater or equal', 'O1 >= O2');
        
        validTypesFor.put('less or equal', NUMBER_TYPES);
        operatorTemplates.put('less or equal', 'O1 <= O2');
        
        validTypesFor.put('contains', STRING_TYPES);
        operatorTemplates.put('contains', 'O1 LIKE \'%O2%\'');
        
        validTypesFor.put('not contains', STRING_TYPES);
        operatorTemplates.put('not contains', '(NOT O1 LIKE \'%O2%\')');
    }
    
    public static final String KEYWORD_WHERE = 'WHERE';
    public static final String TYPE_OBJECT_NOT_HAVING_NAME_FIELD = 'Object_Not_Having_Name_Field';
    public static final String TYPE_OBJECT_DISABLE_NEW_OPTION = 'Disable_New_Option';
    public static final String TYPE_OBJECT_DISABLE_EDIT_OPTION = 'Disable_Edit_Option';
    public static final String TYPE_OBJECT_DISABLE_DELETE_OPTION = 'Disable_Delete_Option';
    public static final String TYPE_OBJECT_NON_QUERYABLE_FIELDS = 'Non_Queryable_Fields';
    
    /**
    * Map to hold mapping of Boolean filters for conversion.
    */
    public static final Map<String, String> BOOLEAN_FILTER_MAPPING = new Map<String, String>
    {
        '1'=>' {A} ',
            '2'=>' {B} ',
            '3'=>' {C} ',
            '4'=>' {D} ',
            '5'=>' {E} ',
            '6'=>' {F} ',
            '7'=>' {G} ',
            '8'=>' {H} ',
            '9'=>' {I} '
	};
        
    public static final Map<String, String> USER_ROLE_OBJECT_ACCESS_MAPPING = new Map<String, String>
    {
        'Read'=> 'Read Only',
        'Edit'=> 'Read/Write',
        'No Access' => 'Private'
    }; 
    
    public static final Set<String> USER_ROLE_ACCESS_SPECIAL_FIELDS = new Set<String>{
        'CaseAccessForAccountOwner', 
        'ContactAccessForAccountOwner', 
        'OpportunityAccessForAccountOwner'
   	};
        
    public static final Set<String> PICKLIST_SELECTABLE_FIELDS = new Set<String>{
        '$Profile.Name'
   	};    
    
    public static final String CUSTOM_TYPE_MATCHING = 'Matching';
    public static final String CUSTOM_TYPE_RATING = 'Rating';
    public static final String CUSTOM_TYPE_COLOR = 'Color';
    public static final String HISTORY_OBJECT_FIELD_FIELD_API_NAME = 'Field';
    public static final String HISTORY_OBJECT_NEW_VALUE_FIELD_API_NAME = 'NewValue';
    public static final String HISTORY_OBJECT_OLD_VALUE_FIELD_API_NAME = 'OldValue';
        
    /**
    * Set to hold all the custom types
    */
    public static final Set<String> SET_OF_CUSTOM_TYPES = new Set<String>{
        dynlistConstants.CUSTOM_TYPE_MATCHING,
        dynlistConstants.CUSTOM_TYPE_RATING,
        dynlistConstants.CUSTOM_TYPE_COLOR
   	};    
}