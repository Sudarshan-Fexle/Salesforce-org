/*
Purpose         :   Page Size Options (For Record Page) - Dynamic Related List
Created By      :   Abhinav Sharma
Created Date    :   08/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/24/2021
*/
global without sharing class dynlistPageSizeOptionsRecordPagePicklist extends VisualEditor.DynamicPickList 
{    
    global override VisualEditor.DataRow getDefaultValue() 
    {
        VisualEditor.DataRow defaultViewOption = new VisualEditor.DataRow('5','5');
        return defaultViewOption;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() 
    {
        VisualEditor.DataRow option1 = new VisualEditor.DataRow('5','5');
        VisualEditor.DataRow option2 = new VisualEditor.DataRow('10','10');
        VisualEditor.DataRow option3 = new VisualEditor.DataRow('15','15');
        
        VisualEditor.DynamicPickListRows viewsOptions = new VisualEditor.DynamicPickListRows();
        viewsOptions.addRow(option1);
        viewsOptions.addRow(option2);
        viewsOptions.addRow(option3);
        return viewsOptions;
    }
}