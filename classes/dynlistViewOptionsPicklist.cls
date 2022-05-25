/*
Purpose         :   Views - Dynamic Related List
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
global without sharing class dynlistViewOptionsPicklist extends VisualEditor.DynamicPickList 
{    
    global override VisualEditor.DataRow getDefaultValue() 
    {
        VisualEditor.DataRow defaultViewOption = new VisualEditor.DataRow(
            dynlistConstants.VIEW_TYPE_TABLE_LABEL,
            dynlistConstants.VIEW_TYPE_TABLE
        );
        return defaultViewOption;
    }
    global override VisualEditor.DynamicPickListRows getValues() 
    {
        VisualEditor.DataRow tableViewOption = new VisualEditor.DataRow(
            dynlistConstants.VIEW_TYPE_TABLE_LABEL,
            dynlistConstants.VIEW_TYPE_TABLE
        );
        VisualEditor.DataRow tileViewOption = new VisualEditor.DataRow(
            dynlistConstants.VIEW_TYPE_TILE_LABEL,
            dynlistConstants.VIEW_TYPE_TILES
        );
        VisualEditor.DataRow kanbanViewOption = new VisualEditor.DataRow(
            dynlistConstants.VIEW_TYPE_KANBAN_LABEL,
            dynlistConstants.VIEW_TYPE_KANBAN
        );
        VisualEditor.DynamicPickListRows viewsOptions = new VisualEditor.DynamicPickListRows();
        viewsOptions.addRow(tableViewOption);
        viewsOptions.addRow(tileViewOption);
        //viewsOptions.addRow(kanbanViewOption);
        return viewsOptions;
    }
}