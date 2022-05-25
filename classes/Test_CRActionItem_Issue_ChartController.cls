/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition. 
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
/**
  *   Purpose         :     Test class for CRActionItem_Issue_ChartController
  *            
  *   Create By       :     Saurabh Kumar  
  * 
  *   Created Date    :     02/15/2017
  *
  *   Revision Log    :     V_1.0 - Created - CR-20170216-10698
  *             
  *   Coverage        :     100%
  **/
@isTest(seeAllData = true)
private class Test_CRActionItem_Issue_ChartController {
  
    /**
     *   Description  :  Test method to test functionality of CRActionItem_Issue_ChartController 
     * 
     *   @argu    :  
     * 
     *   @return    :  Void
     **/
    static testMethod void unitTest(){
        
        //Start testing from here
        Test.startTest();
        
        //Initialization the controller
        CRActionItem_Issue_ChartController controller = new CRActionItem_Issue_ChartController();
        
        //Initialization inner class
        CRActionItem_Issue_ChartController.PieWedgeData piewedgedata = new CRActionItem_Issue_ChartController.PieWedgeData('Test', 100);
        
        //Assertions
        System.assertEquals('Test', piewedgedata.name);
        System.assertEquals(100, piewedgedata.data);
        
        //Calling controller methods
        List<CRActionItem_Issue_ChartController.PieWedgeData> pieData = controller.getPieData();
        
        //Assertions
        System.assert(pieData != null);
        System.assertEquals(3, pieData.size());
        System.assertEquals('New', pieData[0].name);
        System.assertEquals(30, pieData[0].data);
        System.assertEquals('In Progress', pieData[1].name);
        System.assertEquals(15, pieData[1].data);
        System.assertEquals('Blocked', pieData[2].name);
        System.assertEquals(20, pieData[2].data);
        
        //Calling controller method
        String chartType = controller.getChartType();
        System.assert(chartType == null);
        
        //Calling controller method
        controller.setChartType('All');
        
        //Assertions
        System.assertEquals(null, controller.newButtonText);
        System.assertEquals('All', controller.issueType);
        System.assertEquals('All Issues', controller.chartTitle);
        System.assertEquals(null, controller.linkNewButton);
        System.assertEquals(null, controller.linkReportDetail);
        
        chartType = controller.getChartType();
        System.assertEquals('All', controller.chartType);
        
        //Assigning value in controller variable
        controller.showNewButton = true;
        
        controller.getChartTitle();
        System.assertEquals('All Issues', controller.chartTitle);
        
        controller.setChartTitle('Testing for chart title');
        System.assertEquals('Testing for chart title', controller.chartTitle);
        
        controller.getChartTitle();
        System.assertEquals('Testing for chart title', controller.chartTitle);
        
        //Stop testing from here
        Test.stopTest();
    }
}