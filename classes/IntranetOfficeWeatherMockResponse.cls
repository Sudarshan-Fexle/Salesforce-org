/** Description		:	Mock test class to hold fake response for Portal search on Wordpress based system from IntranetSearch page
  * 
  * Created Date	:	09/07/2015
  *
  * Created By		:   Rajeev Jain(Simplyforce)
  *  
  * Current vision	:	v1.0
  *  
  * Revision Logs	:	v1.0 - Created - CR-20141002-7579 - To improve code coverage of IntranetOfficeController class.
  **/
@isTest
global class IntranetOfficeWeatherMockResponse implements HttpCalloutMock{
	
    public final static String LAT = '38.9056';
    public final static String LON = '-77.05';
    
    //Implement the interface method   
    global HTTPResponse respond(HTTPRequest req) {
        
        // Optionally, only send a mock response for a specific endpoint
        HttpResponse response = new HttpResponse();
        
        String endPoint = IntranetOfficeController.WEATHER_URL + IntranetOfficeController.WEATHER_API_KEY + '/' + LAT + ',' + LON + '?exclude=minutely,hourly,alerts,flags';
            
        response.setHeader('Content-Type', 'application/json');
        
        if(req.getEndpoint() == endPoint){
            String responseBody = '{' 
                    + '"latitude":38.9056,' 
                    + '"longitude":-77.05,' 
                    + '"timezone":"America/New_York",' 
                    + '"offset":-4,' 
                    + '"currently":{' 
                    + '"time":1411148249,' 
                    + '"summary":"Mostly Cloudy",' 
                    + '"icon":"partly-cloudy-day",' 
                    + '"nearestStormDistance":70,' 
                    + '"nearestStormBearing":100,' 
                    + '"precipIntensity":0,' 
                    + '"precipProbability":0,' 
                    + '"temperature":72.97,' 
                    + '"apparentTemperature":72.97,' 
                    + '"dewPoint":58.32,' 
                    + '"humidity":0.6,' 
                    + '"windSpeed":5.09,' 
                    + '"windBearing":78,' 
                    + '"visibility":10,' 
                    + '"cloudCover":0.69,' 
                    + '"pressure":1024.83,' 
                    + '"ozone":315.27' 
                    + '},' 
                    + '"daily":{' 
                    + '"summary":"Light rain on Sunday and Friday, with temperatures peaking at 85°F on Sunday.",' 
                    + '"icon":"rain",' 
                    + '"data":[' 
                    + '{' 
                    + '"time":1411099200,' 
                    + '"summary":"Partly cloudy throughout the day.",' 
                    + '"icon":"partly-cloudy-day",' 
                    + '"sunriseTime":1411124070,' 
                    + '"sunsetTime":1411168331,' 
                    + '"moonPhase":0.86,' 
                    + '"precipIntensity":0.0001,' 
                    + '"precipIntensityMax":0.0006,' 
                    + '"precipIntensityMaxTime":1411167600,' 
                    + '"precipProbability":0.01,' 
                    + '"precipType":"rain",' 
                    + '"temperatureMin":57.83,' 
                    + '"temperatureMinTime":1411124400,' 
                    + '"temperatureMax":74.74,' 
                    + '"temperatureMaxTime":1411153200,' 
                    + '"apparentTemperatureMin":57.83,' 
                    + '"apparentTemperatureMinTime":1411124400,' 
                    + '"apparentTemperatureMax":74.74,' 
                    + '"apparentTemperatureMaxTime":1411153200,' 
                    + '"dewPoint":56.31,' 
                    + '"humidity":0.73,' 
                    + '"windSpeed":4.42,' 
                    + '"windBearing":73,' 
                    + '"visibility":9.57,' 
                    + '"cloudCover":0.43,' 
                    + '"pressure":1023.44,' 
                    + '"ozone":314.42' 
                    + '}' 
                    + ']' 
                    + '}' 
                    + '}';
            response.setBody(responseBody);
            response.setStatusCode(200);
        }else{
            response.setBody('No valid request');
            response.setStatusCode(400);
        }
        return response;
    }
}