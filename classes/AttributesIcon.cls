/**
*   Purpose:    Contains the constant image reference id values used in the VF Component AttributesComponent
*               
*   Created By:  Jason Bennett
*    
*    Revision Log:       V1.0 - (Code Added)- Jason Bennett - 10/16/2015 - Created
*
*
**/
public class AttributesIcon {
    
    public string AttributeName {get;set;}
    public string imageId {get;set;}
    public string imageValue {get;set;}
    public string imageAlt {get;set;}
    public string imageTitle {get;set;}
    public string imageRendered {get;set;}
    
    public AttributesIcon(){
        AttributeName = null;
        imageId = null;
        imageValue = null;
        imageAlt = null;
        imageTitle = null;
        imageRendered = null;
    }
    
    public AttributesIcon(string aName){
        //Normally, we would get values from an object, but we are mocking the process for now before moving to Custom Metadata...
        AttributeName = aName;
        if(AttributeName == 'HasSOXObject'){
            imageId = 'HasSOXObject';
            imageValue = '{!URLFOR($Resource.AttributeIcons,\'cloud-socks-darkblue24.png\')}';
            imageAlt = 'SOX Object';
            imageTitle = 'SOX Object';
            imageRendered = 'false';
        }else if(AttributeName == 'HasIntegration'){
            imageId = 'HasIntegration';
            imageValue = '{!URLFOR($Resource.AttributeIcons,\'connect24.png\')}';
            imageAlt = 'Used in Integrations';
            imageTitle = 'Used in Integrations';
            imageRendered = 'false';
        }else if(AttributeName == 'HasManagedPackage'){
            imageId = 'HasManagedPackage';
            imageValue = '{!URLFOR($Resource.AttributeIcons,\'lock24.png\')}';
            imageAlt = 'Part of a Managed Package';
            imageTitle = 'Part of a Managed Package';
            imageRendered = 'false';
        }else if(AttributeName == 'HasHighImpact'){
            imageId = 'HasHighImpact';
            imageValue = '{!URLFOR($Resource.AttributeIcons,\'boxing-gloves-icon24.png\')}';
            imageAlt = 'High Impact';
            imageTitle = 'High Impact';
            imageRendered = 'false';
        }else if(AttributeName == 'HasDoubleDeployment'){
            imageId = 'HasDoubleDeployment';
            imageValue = '{!URLFOR($Resource.AttributeIcons,\'arrow_refresh24.png\')}';
            imageAlt = 'Requires Double Deployment';
            imageTitle = 'Requires Double Deployment';
            imageRendered = 'false';
        }else if(AttributeName == 'HasDuplicateModCR'){
            imageId = 'HasDuplicateModCR';
            imageValue = '{!URLFOR($Resource.AttributeIcons,\'pictures24.png\')}';
            imageAlt = 'Duplicate Modifications on CR';
            imageTitle = 'Duplicate Modifications on CR';
            imageRendered = 'false';
        }else if(AttributeName == 'HasDuplicateModRelease'){
            imageId = 'HasDuplicateModRelease';
            imageValue = '{!URLFOR($Resource.AttributeIcons,\'photos24.png\')}';
            imageAlt = 'Duplicate Modifications on Release';
            imageTitle = 'Duplicate Modifications on Release';
            imageRendered = 'false';
        }
    }
    
    public static Component.Apex.Image createAttributeImage(String attributeName){
        AttributesIcon ic = new AttributesIcon(attributeName);
        Component.Apex.Image img = new Component.Apex.Image();
        img.id = ic.imageId;
        img.expressions.value = ic.imageValue;
        img.alt = ic.imageAlt;
        img.title = ic.imageTitle;
        img.rendered = true;
        img.style = 'margin:3px;';
        return img;
    }    
    
}