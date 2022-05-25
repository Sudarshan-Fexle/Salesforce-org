/**
* Desription      :  Wrapper class to create Email template for TravelCompRequests
*
* Create By       : Chirag Soni
* 
* Create Date     : 10/25/2021
*
* Revision Logs   :   V1.0 - Created - 10/25/2021
**/ 

public without sharing class TravelCompEmailTemplateWrapper {
    
    /**
* Desription      : Method to Create Email template for Internal Travel Emails 
*
* Create By       : Chirag Soni
* 
* Create Date     : 10/25/2021
*
* Revision Logs   : V1.0 - Created - 10/25/2021
**/ 
    
    public static String getInternalTravelEmailBody(Registration__c reg, Venue__c venue, String EABLogo) {
        
        String htmlBody = '';
        //Variable to store HotelRoom is blocked
        Boolean isHoltelRoomBlock = false;
        if(venue != null){
            if(venue.Accommodations__c){
                isHoltelRoomBlock = true;
            }
        }
        if(reg!=null){
            
            htmlBody = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"><head><!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->\n'+
                '<meta name="viewport" content="width=device-width">\n'+
                '	<!--[if !mso]><!-->\n'+
                '	<meta http-equiv="X-UA-Compatible" content="IE=edge">\n'+
                '	<!--<![endif]-->\n'+
                '	<title></title>\n'+
                '	<!--[if !mso]><!-->\n'+
                '	<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">\n'+
                '	<!--<![endif]-->\n'+
                '	<style type="text/css">\n'+
                '		body {\n'+
                '			margin: 0;\n'+
                '			padding: 0;\n'+
                '		}\n'+
                '\n'+
                '		table,\n'+
                '		td,\n'+
                '		tr {\n'+
                '			vertical-align: top;\n'+
                '			border-collapse: collapse;\n'+
                '		}\n'+
                '\n'+
                '		* {\n'+
                '			line-height: inherit;\n'+
                '		}\n'+
                '\n'+
                '		a[x-apple-data-detectors=true] {\n'+
                '			color: inherit !important;\n'+
                '			text-decoration: none !important;\n'+
                '		}\n'+
                '	</style>\n'+
                '	<style type="text/css" id="media-query">\n'+
                '		@media (max-width: 620px) {\n'+
                '\n'+
                '			.block-grid,\n'+
                '			.col {\n'+
                '				min-width: 320px !important;\n'+
                '				max-width: 100% !important;\n'+
                '				display: block !important;\n'+
                '			}\n'+
                '\n'+
                '			.block-grid {\n'+
                '				width: 100% !important;\n'+
                '			}\n'+
                '\n'+
                '			.col {\n'+
                '				width: 100% !important;\n'+
                '			}\n'+
                '\n'+
                '			.col_cont {\n'+
                '				margin: 0 auto;\n'+
                '			}\n'+
                '\n'+
                '			img.fullwidth,\n'+
                '			img.fullwidthOnMobile {\n'+
                '				width: 100% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col {\n'+
                '				min-width: 0 !important;\n'+
                '				display: table-cell !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack.two-up .col {\n'+
                '				width: 50% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num2 {\n'+
                '				width: 16.6% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num3 {\n'+
                '				width: 25% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num4 {\n'+
                '				width: 33% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num5 {\n'+
                '				width: 41.6% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num6 {\n'+
                '				width: 50% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num7 {\n'+
                '				width: 58.3% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num8 {\n'+
                '				width: 66.6% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num9 {\n'+
                '				width: 75% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num10 {\n'+
                '				width: 83.3% !important;\n'+
                '			}\n'+
                '\n'+
                '			.video-block {\n'+
                '				max-width: none !important;\n'+
                '			}\n'+
                '\n'+
                '			.mobile_hide {\n'+
                '				min-height: 0px;\n'+
                '				max-height: 0px;\n'+
                '				max-width: 0px;\n'+
                '				display: none;\n'+
                '				overflow: hidden;\n'+
                '				font-size: 0px;\n'+
                '			}\n'+
                '\n'+
                '			.desktop_hide {\n'+
                '				display: block !important;\n'+
                '				max-height: none !important;\n'+
                '			}\n'+
                '\n'+
                '			.img-container.big img {\n'+
                '				width: auto !important;\n'+
                '			}\n'+
                '		}\n'+
                '	</style>\n'+
                '	<style type="text/css" id="menu-media-query">\n'+
                '		@media (max-width: 620px) {\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links {\n'+
                '				display: none !important;\n'+
                '				padding: 5px 0;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links span.sep {\n'+
                '				display: none;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]:checked~.menu-links,\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-trigger {\n'+
                '				display: block !important;\n'+
                '				max-width: none !important;\n'+
                '				max-height: none !important;\n'+
                '				font-size: inherit !important;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links>a,\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links>span.label {\n'+
                '				display: block !important;\n'+
                '				text-align: center;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]:checked~.menu-trigger .menu-close {\n'+
                '				display: block !important;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]:checked~.menu-trigger .menu-open {\n'+
                '				display: none !important;\n'+
                '			}\n'+
                '\n'+
                '			#menuka2yed~div label {\n'+
                '				border-radius: 0% !important;\n'+
                '			}\n'+
                '\n'+
                '			#menuka2yed:checked~.menu-links {\n'+
                '				background-color: #000000 !important;\n'+
                '			}\n'+
                '\n'+
                '			#menuka2yed:checked~.menu-links a {\n'+
                '				color: #ffffff !important;\n'+
                '			}\n'+
                '\n'+
                '			#menuka2yed:checked~.menu-links span {\n'+
                '				color: #ffffff !important;\n'+
                '			}\n'+
                '		}\n'+
                '	</style>\n'+
                '</head>\n'+
                '\n'+
                '<body class="clean-body" style="margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #ededed;">\n'+
                '	<!--[if IE]><div class="ie-browser"><![endif]-->\n'+
                '	<table class="nl-container" style="table-layout: fixed; vertical-align: top; min-width: 320px; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #ededed; width: 100%;" cellpadding="0" cellspacing="0" role="presentation" width="100%" bgcolor="#ededed" valign="top">\n'+
                '		<tbody>\n'+
                '			<tr style="vertical-align: top;" valign="top">\n'+
                '				<td style="word-break: break-word; vertical-align: top;" valign="top">\n'+
                '					<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color:#ededed"><![endif]-->\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #00355f;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#00355f;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#00355f"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#00355f;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:15px; padding-bottom:15px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:15px; padding-bottom:15px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; font-size: 16px; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="color: #ffffff; font-size: 16px;"><strong><span style="">EAB Electronic Travel Assistance Authorization</span></strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #ffffff;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#ffffff;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#ffffff"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#ffffff;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Request Overview</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; color: #00355f; font-family: Verdana, Geneva, sans-serif; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Registration Number: '+reg.Name+'</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Offering: '+reg.What_Travel_is_being_offered__c+'</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Valid Through: '+reg.Valid_Through_Date__c+'</span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #ffffff;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#ffffff;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#ffffff"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#ffffff;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Partner Guest</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+reg.Contact__r.Name+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+reg.Contact_Email__c+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotBlank(reg.Contact__r.Phone)? reg.Contact__r.Phone : '')+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotBlank(reg.Contact__r.Account.Account_Formal_Name__c)? reg.Contact__r.Account.Account_Formal_Name__c :'')+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotEmpty(reg.Contact__r.Account.Primary_City__c) ? ''+reg.Contact__r.Account.Primary_City__c+', ' : '') + '' +(String.isNotEmpty(reg.Contact__r.Account.Primary_State_Province__c) ? ''+reg.Contact__r.Account.Primary_State_Province__c : '') + (String.isNotEmpty(reg.Contact__r.Account.Primary_Postal_Code__c) ? ''+reg.Contact__r.Account.Primary_Postal_Code__c : '') +'</span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Partner Guest Assistant</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotEmpty(reg.Assistant__c) ? ''+reg.Assistant__c+'</span> </p> ' :'</p>')+'\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotEmpty(reg.Assistant_Email__c) ? ''+reg.Assistant_Email__c : '')+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotEmpty(reg.Contact__r.AssistantPhone) ? ''+reg.Contact__r.AssistantPhone : '')+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotEmpty(reg.Contact__r.Account.Account_Formal_Name__c) ? ''+reg.Contact__r.Account.Account_Formal_Name__c : '')+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">'+(String.isNotEmpty(reg.Contact__r.Account.Primary_City__c) ? ''+reg.Contact__r.Account.Primary_City__c : '')+', '+(String.isNotEmpty(reg.Contact__r.Account.Primary_State_Province__c) ? ''+reg.Contact__r.Account.Primary_State_Province__c : '') + (String.isNotEmpty(reg.Contact__r.Account.Primary_Postal_Code__c) ? ''+reg.Contact__r.Account.Primary_Postal_Code__c : '')+'</span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Event Information</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Event: '+reg.EAB_Event__r.Public_Name__c+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Location: '+(String.isNotEmpty(reg.EAB_Event__r.Location__c) ? ''+reg.EAB_Event__r.Location__c : '')+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Venue: '+((venue != null && String.isNotEmpty(venue.Name)) ? ''+venue.Name: '')+'</p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Event Manager: '+(String.isNotEmpty(reg.EAB_Event__r.Event_Manager__r.Name) ? ''+reg.EAB_Event__r.Event_Manager__r.Name : '')+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Date(s): '+reg.EAB_Event__r.Begins_Long_Date__c+' through '+reg.EAB_Event__r.Ends_Long_Date__c+'</span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Travel Information</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Arrive at event location no later than '+reg.Must_Arrive_at_Meeting_Location_By__c.format() +' Local Time</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Depart event location no earlier than '+reg.Must_Depart_No_Earlier_Than__c.format() +' Local Time</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n';
            //Send Internal Travel Email when hotel room is blocked
            if(isHoltelRoomBlock){
                htmlBody += '<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;"><span style="">Hotel Room Block: </span>'+(String.isNotEmpty(venue.Name) ? ''+venue.Name : 'Blank') +' located at '+(String.isNotEmpty(venue.Venue_Address__c) ? ''+venue.Venue_Address__c : 'Blank') +'</span></p>\n';
            }
            else{
                htmlBody += '<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;"><span style="">Hotel Room Block: No hotel room block information listed in event system' +'</span></p>\n';
            }
            
            htmlBody+= ''+
                
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;"><em>If there are no more available rooms, please book the closest appropriate property to the event location. For further information or assistance contact the Event Manager.</em></span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;"><em>Please book travel for Monday-Friday only.</em></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Requestor and Approver Information</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Approver: '+reg.Department_Authorization__r.Name+'</span></p>\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000;">Requester: '+reg.Requester_Name__r.Name+'</span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #00355f;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#00355f;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#00355f"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#00355f;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:15px; padding-bottom:15px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:15px; padding-bottom:15px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<div class="img-container center fixedwidth" align="center" style="padding-right: 5px;padding-left: 5px;">\n'+
                '												<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr style="line-height:0px"><td style="padding-right: 5px;padding-left: 5px;" align="center"><![endif]-->\n'+
                '												<div style="font-size:1px;line-height:10px">&nbsp;</div><img class="center fixedwidth" align="center" border="0" src="'+EABLogo+'" alt="EAB Logo" title="EAB Logo" style="text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: 0; width: 120px; max-width: 100%; display: block;" width="120">\n'+
                '												<div style="font-size:1px;line-height:10px">&nbsp;</div>\n'+
                '												<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											</div>\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:transparent;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:transparent"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 0px solid transparent; height: 20px; width: 100%;" align="center" role="presentation" height="20" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" height="20" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt;" valign="top">\n'+
                '												<tr style="vertical-align: top;" valign="top">\n'+
                '													<td style="word-break: break-word; vertical-align: top; padding-top: 5px; padding-bottom: 5px; padding-left: 0px; padding-right: 0px; text-align: center; font-size: 0px;" align="center" valign="top">\n'+
                '														<div class="menu-links">\n'+
                '															<!--[if mso]>\n'+
                '\n'+
                '</body>\n'+
                '\n'+
                '</html>';
            
            
        }
        return htmlBody;
    }
    
    public static String getPartnerFacingEmailBody(Registration__c reg, String EABLogo) {
        
        String htmlBody = '';
        if(reg != null){
            
            
            //setting style of html template
            htmlBody += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"><head><!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->\n'+
                '<meta name="viewport" content="width=device-width">\n'+
                '	<!--[if !mso]><!-->\n'+
                '	<meta http-equiv="X-UA-Compatible" content="IE=edge">\n'+
                '	<!--<![endif]-->\n'+
                '	<title></title>\n'+
                '	<!--[if !mso]><!-->\n'+
                '	<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">\n'+
                '	<!--<![endif]-->\n'+
                '	<style type="text/css">\n'+
                '		body {\n'+
                '			margin: 0;\n'+
                '			padding: 0;\n'+
                '		}\n'+
                '\n'+
                '		table,\n'+
                '		td,\n'+
                '		tr {\n'+
                '			vertical-align: top;\n'+
                '			border-collapse: collapse;\n'+
                '		}\n'+
                '\n'+
                '		* {\n'+
                '			line-height: inherit;\n'+
                '		}\n'+
                '\n'+
                '		a[x-apple-data-detectors=true] {\n'+
                '			color: inherit !important;\n'+
                '			text-decoration: none !important;\n'+
                '		}\n'+
                '	</style>\n'+
                '	<style type="text/css" id="media-query">\n'+
                '		@media (max-width: 620px) {\n'+
                '\n'+
                '			.block-grid,\n'+
                '			.col {\n'+
                '				min-width: 320px !important;\n'+
                '				max-width: 100% !important;\n'+
                '				display: block !important;\n'+
                '			}\n'+
                '\n'+
                '			.block-grid {\n'+
                '				width: 100% !important;\n'+
                '			}\n'+
                '\n'+
                '			.col {\n'+
                '				width: 100% !important;\n'+
                '			}\n'+
                '\n'+
                '			.col_cont {\n'+
                '				margin: 0 auto;\n'+
                '			}\n'+
                '\n'+
                '			img.fullwidth,\n'+
                '			img.fullwidthOnMobile {\n'+
                '				width: 100% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col {\n'+
                '				min-width: 0 !important;\n'+
                '				display: table-cell !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack.two-up .col {\n'+
                '				width: 50% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num2 {\n'+
                '				width: 16.6% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num3 {\n'+
                '				width: 25% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num4 {\n'+
                '				width: 33% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num5 {\n'+
                '				width: 41.6% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num6 {\n'+
                '				width: 50% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num7 {\n'+
                '				width: 58.3% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num8 {\n'+
                '				width: 66.6% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num9 {\n'+
                '				width: 75% !important;\n'+
                '			}\n'+
                '\n'+
                '			.no-stack .col.num10 {\n'+
                '				width: 83.3% !important;\n'+
                '			}\n'+
                '\n'+
                '			.video-block {\n'+
                '				max-width: none !important;\n'+
                '			}\n'+
                '\n'+
                '			.mobile_hide {\n'+
                '				min-height: 0px;\n'+
                '				max-height: 0px;\n'+
                '				max-width: 0px;\n'+
                '				display: none;\n'+
                '				overflow: hidden;\n'+
                '				font-size: 0px;\n'+
                '			}\n'+
                '\n'+
                '			.desktop_hide {\n'+
                '				display: block !important;\n'+
                '				max-height: none !important;\n'+
                '			}\n'+
                '\n'+
                '			.img-container.big img {\n'+
                '				width: auto !important;\n'+
                '			}\n'+
                '		}\n'+
                '	</style>\n'+
                '	<style type="text/css" id="menu-media-query">\n'+
                '		@media (max-width: 620px) {\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links {\n'+
                '				display: none !important;\n'+
                '				padding: 5px 0;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links span.sep {\n'+
                '				display: none;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]:checked~.menu-links,\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-trigger {\n'+
                '				display: block !important;\n'+
                '				max-width: none !important;\n'+
                '				max-height: none !important;\n'+
                '				font-size: inherit !important;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links>a,\n'+
                '			.menu-checkbox[type="checkbox"]~.menu-links>span.label {\n'+
                '				display: block !important;\n'+
                '				text-align: center;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]:checked~.menu-trigger .menu-close {\n'+
                '				display: block !important;\n'+
                '			}\n'+
                '\n'+
                '			.menu-checkbox[type="checkbox"]:checked~.menu-trigger .menu-open {\n'+
                '				display: none !important;\n'+
                '			}\n'+
                '\n'+
                '			#menu9lbxog~div label {\n'+
                '				border-radius: 0% !important;\n'+
                '			}\n'+
                '\n'+
                '			#menu9lbxog:checked~.menu-links {\n'+
                '				background-color: #000000 !important;\n'+
                '			}\n'+
                '\n'+
                '			#menu9lbxog:checked~.menu-links a {\n'+
                '				color: #ffffff !important;\n'+
                '			}\n'+
                '\n'+
                '			#menu9lbxog:checked~.menu-links span {\n'+
                '				color: #ffffff !important;\n'+
                '			}\n'+
                '		}\n'+
                '	</style>\n'+
                '</head>\n'+
                '\n'+
                '<body class="clean-body" style="margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #ededed;">\n'+
                '	<!--[if IE]><div class="ie-browser"><![endif]-->\n'+
                '	<table class="nl-container" style="table-layout: fixed; vertical-align: top; min-width: 320px; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #ededed; width: 100%;" cellpadding="0" cellspacing="0" role="presentation" width="100%" bgcolor="#ededed" valign="top">\n'+
                '		<tbody>\n'+
                '			<tr style="vertical-align: top;" valign="top">\n'+
                '				<td style="word-break: break-word; vertical-align: top;" valign="top">\n'+
                '					<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color:#ededed"><![endif]-->\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #ffffff;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#ffffff;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#ffffff"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#ffffff;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 0px solid transparent; height: 25px; width: 100%;" align="center" role="presentation" height="25" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" height="25" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#555555;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; color: #555555; font-family: Verdana, Geneva, sans-serif; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">'+reg.First_Name__c+',</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">I am pleased to extend travel assistance to you for the '+reg.EAB_Event__r.Public_Name__c+ ' in ' + (String.isNotEmpty(reg.EAB_Event__r.Location__c) ? ''+reg.EAB_Event__r.Location__c + '' : '') +' on '+ reg.EAB_Event__r.Begins_Long_Date__c +'. We can accommodate your ';
            if(reg.What_Travel_is_being_offered__c == 'Hotel'){
                    htmlBody += 'hotel room and tax for ' + reg.Maximum_Hotel_Nights__c+' night(s), ';
                }
                  												
                else if(reg.What_Travel_is_being_offered__c == 'Airfare'){
                     htmlBody += 'airfare '; 
                }
              													
                else if(reg.What_Travel_is_being_offered__c == 'Hotel and Airfare'){
                    htmlBody += 'hotel room and tax for '+ reg.Maximum_Hotel_Nights__c+ ' night(s), as well as airfare, ';
                }
            htmlBody += 'so that you are able to join us.</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">To make your travel arrangements, use the information provided below to contact our dedicated corporate travel agents at 202-747-0909 during the hours of 8:30 a.m. – 8:00 p.m. Eastern Time. Please be sure to book your travel no later than <strong>'+reg.Valid_Through_Date__c+',</strong> as our agents will not be able to make any travel arrangements after this date.</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Please note that you do not need to save a receipt or submit a bill to us as all charges will automatically be billed to EAB\'s account.</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Should your plans change, and you are unable to attend the event, please contact me.</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">If you have questions, please do not hesitate to call me.</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">We look forward to hosting you at the '+reg.EAB_Event__r.Public_Name__c+'!</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Best,</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">'+reg.Requester_Name__r.Name+'</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #00355f;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#00355f;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#00355f"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#00355f;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:15px; padding-bottom:15px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:15px; padding-bottom:15px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; font-size: 16px; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="color: #ffffff; font-size: 16px;"><strong><span style="">EAB Electronic Travel Assistance Authorization</span></strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #ffffff;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#ffffff;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#ffffff"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#ffffff;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#555555;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="font-size: 12px; line-height: 1.2; font-family: Verdana, Geneva, sans-serif; color: #555555; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; line-height: 1.2; word-break: break-word; font-size: 12px; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;"><strong>To make your travel arrangements, please contact our dedicated corporate travel agents at 202-747-0909 during the hours of 8:30 a.m. – 8:00 p.m. Eastern Time.</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #ffffff;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#ffffff;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#ffffff"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#ffffff;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Registration Details</strong></span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; color: #00355f; font-family: Verdana, Geneva, sans-serif; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Valid Through: '+reg.Valid_Through_Date__c+'</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Guest: '+reg.Contact__r.Name+'</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Event: '+reg.EAB_Event__r.Public_Name__c+'</span></p>\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 12px; color: #000000;">Registration Number: '+reg.Name+'</span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #ffffff;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#ffffff;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#ffffff"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#ffffff;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+ 
                '											</table>\n';
            if(reg.What_Travel_is_being_offered__c == 'Hotel'){
                htmlBody += ''+'<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Hotel Room and Tax Authorization</strong></span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n'+
                    '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                    '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; color: #00355f; font-family: Verdana, Geneva, sans-serif; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">The hotel will require a credit card from the guest for incidentals and any additional charges made to the room. The travel agents will attempt to host the guest in the event hotel, but if it is filled upon booking, then they will find alternate accommodations nearby. The nights between the dates of the event will be covered as well as the night prior to an event when the first day begins before noon. We are pleased to accommodate requests to book additional nights at the guest\'s expense.</span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n';
            }else if (reg.What_Travel_is_being_offered__c == 'Airfare'){
                htmlBody += ''+'<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Air Ticket Authorization</strong></span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n'+
                    '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                    '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">Round-trip economy class air travel provided from guest\'s city to event location using EAB\'s choice of carrier.</span></p>\n'+
                    '													<p style="margin: 0; font-size: 14px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 17px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">Please note that TSA regulations now require that the guest provide the following information when booking:</span></p>\n'+
                    '													<ul>\n'+
                    '														<li style="font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px;"><span style="color: #000000; font-size: 12px;">Traveler\'s Full Name as it appears on the government-issued ID which will be used at the airport</span></li>\n'+
                    '														<li style="font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px;"><span style="color: #000000; font-size: 12px;">Traveler\'s Date of Birth</span></li>\n'+
                    '														<li style="font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px;"><span style="color: #000000; font-size: 12px;">Traveler\'s Gender</span></li>\n'+
                    '													</ul>\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">Please have this information on hand when calling our travel office or they will be unable to book the guest\'s air arrangements.</span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n';
            }
            else if(reg.What_Travel_is_being_offered__c == 'Hotel and Airfare'){
                htmlBody += ''+' <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Hotel Room and Tax Authorization</strong></span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n'+
                    '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                    '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; color: #00355f; font-family: Verdana, Geneva, sans-serif; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">The hotel will require a credit card from the guest for incidentals and any additional charges made to the room. The travel agents will attempt to host the guest in the event hotel, but if it is filled upon booking, then they will find alternate accommodations nearby. The nights between the dates of the event will be covered as well as the night prior to an event when the first day begins before noon. We are pleased to accommodate requests to book additional nights at the guest\'s expense.</span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n'+
                    '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                    '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                    '												<tbody>\n'+
                    '													<tr style="vertical-align: top;" valign="top">\n'+
                    '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                    '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                    '																<tbody>\n'+
                    '																	<tr style="vertical-align: top;" valign="top">\n'+
                    '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                    '																	</tr>\n'+
                    '																</tbody>\n'+
                    '															</table>\n'+
                    '														</td>\n'+
                    '													</tr>\n'+
                    '												</tbody>\n'+
                    '											</table>\n'+
                    '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 19px; margin-top: 0; margin-bottom: 0;"><span style="font-size: 16px;"><strong>Air Ticket Authorization</strong></span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n'+
                    '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                    '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                    '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                    '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; font-family: Verdana, Geneva, sans-serif; color: #00355f; mso-line-height-alt: 14px;">\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">Round-trip economy class air travel provided from guest\'s city to event location using EAB\'s choice of carrier.</span></p>\n'+
                    '													<p style="margin: 0; font-size: 14px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 17px; margin-top: 0; margin-bottom: 0;">&nbsp;</p>\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">Please note that TSA regulations now require that the guest provide the following information when booking:</span></p>\n'+
                    '													<ul>\n'+
                    '														<li style="font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px;"><span style="color: #000000; font-size: 12px;">Traveler\'s Full Name as it appears on the government-issued ID which will be used at the airport</span></li>\n'+
                    '														<li style="font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px;"><span style="color: #000000; font-size: 12px;">Traveler\'s Date of Birth</span></li>\n'+
                    '														<li style="font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px;"><span style="color: #000000; font-size: 12px;">Traveler\'s Gender</span></li>\n'+
                    '													</ul>\n'+
                    '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">Please have this information on hand when calling our travel office or they will be unable to book the guest\'s air arrangements.</span></p>\n'+
                    '												</div>\n'+
                    '											</div>\n';
            }
            
            
            
            htmlBody += ''+'											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 35px; padding-left: 35px; padding-top: 10px; padding-bottom: 10px; font-family: Verdana, sans-serif"><![endif]-->\n'+
                '											<div style="color:#00355f;font-family:Verdana, Geneva, sans-serif;line-height:1.2;padding-top:10px;padding-right:35px;padding-bottom:10px;padding-left:35px;">\n'+
                '												<div class="txtTinyMce-wrapper" style="line-height: 1.2; font-size: 12px; color: #00355f; font-family: Verdana, Geneva, sans-serif; mso-line-height-alt: 14px;">\n'+
                '													<p style="margin: 0; font-size: 12px; line-height: 1.2; word-break: break-word; mso-line-height-alt: 14px; margin-top: 0; margin-bottom: 0;"><span style="color: #000000; font-size: 12px;">All other expenses including ground transportation, transfers, parking, meals, and incidentals are not included. All covered charges are billed directly to our accounts. No direct reimbursements will be made for charges not made through our corporate travel agents and billed directly to our accounts. May only be used by guest listed above. Non-transferable. Not valid for arrangements made after &quot;Valid Through&quot; date. Contact '+reg.Requester_Name__r.Name+'  with questions.</span></p>\n'+
                '												</div>\n'+
                '											</div>\n'+
                '											<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 2px dotted #00355F; width: 100%;" align="center" role="presentation" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: #00355f;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:#00355f;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:#00355f"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:#00355f;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:15px; padding-bottom:15px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:15px; padding-bottom:15px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<div class="img-container center fixedwidth" align="center" style="padding-right: 5px;padding-left: 5px;">\n'+
                '												<!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr style="line-height:0px"><td style="padding-right: 5px;padding-left: 5px;" align="center"><![endif]-->\n'+
                '												<div style="font-size:1px;line-height:10px">&nbsp;</div><img class="center fixedwidth" align="center" border="0" src="'+EABLogo+'" alt="EAB Logo" title="EAB Logo" style="text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: 0; width: 120px; max-width: 100%; display: block;" width="120">\n'+
                '												<div style="font-size:1px;line-height:10px">&nbsp;</div>\n'+
                '												<!--[if mso]></td></tr></table><![endif]-->\n'+
                '											</div>\n'+
                '											<!--[if (!mso)&(!IE)]><!-->\n'+
                '										</div>\n'+
                '										<!--<![endif]-->\n'+
                '									</div>\n'+
                '								</div>\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n'+
                '							</div>\n'+
                '						</div>\n'+
                '					</div>\n'+
                '					<div style="background-color:transparent;">\n'+
                '						<div class="block-grid " style="min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;">\n'+
                '							<div style="border-collapse: collapse;display: table;width: 100%;background-color:transparent;">\n'+
                '								<!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:600px"><tr class="layout-full-width" style="background-color:transparent"><![endif]-->\n'+
                '								<!--[if (mso)|(IE)]><td align="center" width="600" style="background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->\n'+
                '								<div class="col num12" style="min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;">\n'+
                '									<div class="col_cont" style="width:100% !important;">\n'+
                '										<!--[if (!mso)&(!IE)]><!-->\n'+
                '										<div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">\n'+
                '											<!--<![endif]-->\n'+
                '											<table class="divider" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" role="presentation" valign="top">\n'+
                '												<tbody>\n'+
                '													<tr style="vertical-align: top;" valign="top">\n'+
                '														<td class="divider_inner" style="word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px;" valign="top">\n'+
                '															<table class="divider_content" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 0px solid transparent; height: 20px; width: 100%;" align="center" role="presentation" height="20" valign="top">\n'+
                '																<tbody>\n'+
                '																	<tr style="vertical-align: top;" valign="top">\n'+
                '																		<td style="word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;" height="20" valign="top"><span></span></td>\n'+
                '																	</tr>\n'+
                '																</tbody>\n'+
                '															</table>\n'+
                '														</td>\n'+
                '													</tr>\n'+
                '												</tbody>\n'+
                '											</table>\n'+
                '											<table width="100%" cellpadding="0" cellspacing="0" border="0" role="presentation" style="table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt;" valign="top">\n'+
                '												<tr style="vertical-align: top;" valign="top">\n'+
                '													<td style="word-break: break-word; vertical-align: top; padding-top: 5px; padding-bottom: 5px; padding-left: 0px; padding-right: 0px; text-align: center; font-size: 0px;" align="center" valign="top">\n'+
                '														<div class="menu-links">\n'+
                '															\n'+
                '\n'+
                '</body>\n'+
                '\n'+
                '</html>';
        }
        return htmlBody;
    }
}