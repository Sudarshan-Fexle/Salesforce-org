/**
*	Desription      :	Class to have the Generic Utility Methods
* 
*	Created By      :   Abhinav Sharma
* 
*  Created Date    :    11/21/2019
* 
*  Revision Logs   :    V1.0 - Created
*
**/
public without sharing class Utilities 
{
    private static String pkgPrefix = null;
	public static String getPackagePrefix()
    {
		if (pkgPrefix == null) 
        {
			pkgPrefix = SOBjectType.Membership__c.Name.substringBefore('Membership__c');
		}
		return pkgPrefix;
	}
    
    public static String removeHtml(String input) 
    {
        return input.replaceAll('<.*?>', ' ');
    }
	
    public static String removeBadUtfChars(String input) 
    {
		String output = '';
		if(input != null){
			output = input.replaceAll('[^\\u0009|\\u000A|\\u000D|\\u0020-\\uF7FF|\\uE000-\\uFFFD]', '');
		}
		return output;
	}
    
    public static String removeScript(String input) 
    {
		List<String> EVENT_HANDLERS = new List<String> {
				'javascript:','</iframe','</script','<iframe', '<script', 'onclick','oncontextmenu','ondblclick','onmousedown','onmouseenter','onmouseleave','onmousemove',
				'onmouseover','onmouseout','onmouseup','onkeydown','onkeypress','onkeyup','onabort','onbeforeunload',
				'onerror','onhashchange','onload','onpageshow','onpagehide','onresize','onscroll','onunload','onblur',
				'onchange','onfocus','onfocusin','onfocusout','oninput','oninvalid','onreset','onsearch','onselect',
				'onsubmit','ondrag','ondragend','ondragenter','ondragleave','ondragover','ondragstart','ondrop','oncopy',
				'oncut','onpaste','onafterprint','onbeforeprint','onabort','oncanplay','oncanplaythrough','ondurationchange',
				'onemptied','onended','onerror','onloadeddata','onloadedmetadata','onloadstart','onpause','onplay',
				'onplaying','onprogress','onratechange','onseeked','onseeking','onstalled','onsuspend','ontimeupdate',
				'onvolumechange','onwaiting','animationend','animationiteration','animationstart','transitionend','onerror',
				'onmessage','onopen','onmousewheel','ononline','onoffline','onpopstate','onshow','onstorage','ontoggle',
				'onwheel','ontouchcancel','ontouchend','ontouchmove','ontouchstart'
		};
		String output = input;
		if(output != null) 
        {
			output = removeBadUtfChars(output);
			for (String event : EVENT_HANDLERS) 
            {
				output = output.replaceAll('(?i)' + event, ' ');
			}
		}
		return output;
	}
}