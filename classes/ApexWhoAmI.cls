@RestResource(urlMapping='/ApexWhoAmI/*')
global with sharing class ApexWhoAmI {

    @HttpGet
    global static string Get() {
        return UserInfo.getName();
    }
}