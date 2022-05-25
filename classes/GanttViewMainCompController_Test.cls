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
  *   Purpose         :     Test class for GanttView_At_PackageDetailController
  *            
  *   Create By       :     Divya Bharadwaj(simplyforce)
  * 
  *   Created Date    :     09/11/2017
  *
  *   Revision Log    :     V_1.0 - Created
  *
  *   Coverage        :     80%
  **/ 
@isTest(seeAllData = false)
private class GanttViewMainCompController_Test {

  /**
    * @Description  : This method used to test functionality
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    **/
    static testmethod void testMyUnitTest() {

		GanttViewMainCompController grantController = new GanttViewMainCompController();

		grantController.applicableConfigInstance = [select Id From Gantt_View_Manager__mdt ];
		grantController.getGanttChartJSON();

    }
}