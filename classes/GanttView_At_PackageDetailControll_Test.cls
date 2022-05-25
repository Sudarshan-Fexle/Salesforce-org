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
private class GanttView_At_PackageDetailControll_Test {
	
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

		//List to hold Record type
		List<RecordType> packageRecordTypeList = [select id from RecordType
                             where sObjecttype = 'Package__C' order by Name  ASC];

        //Insert release record
        List<Package__C> packages = new List<Package__C> ();

		//Add record to list
		packages.add(new  Package__C (recordTypeId = packageRecordTypeList[1].Id, Name = 'TestPackage' ));	

		//Insert 
		insert packages;

		//Set current Page
		PageReference pageRef = Page.GanttView_At_PackageDetail;
        Test.setCurrentPage(pageRef);

        //Standard controller instance
        ApexPages.StandardController sc = new ApexPages.standardController(packages[0]);

		//Instance of Controller
		GanttView_At_PackageDetailController packDeatil = new GanttView_At_PackageDetailController(sc);

		//Hold map 
		Map<String, List<Gantt_View_Manager__mdt>> mapOfGanttManagerConfigurationM = packDeatil.mapOfGanttManagerConfigurationManager;

		packDeatil.init();
	}
}