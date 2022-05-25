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
@isTest(seeAllData = false)
private class Test_AttributesIcon {
    
	@isTest
    static void testAttribute1(){
        AttributesIcon aI = new AttributesIcon();
        system.assertEquals(null , aI.AttributeName);
        system.assertEquals(null , aI.imageId);
        system.assertEquals(null , aI.imageValue);
        system.assertEquals(null , aI.imageAlt);
        system.assertEquals(null , aI.imageTitle);
        system.assertEquals(null , aI.imageRendered);
    }
    
    @isTest
    static void testAttribute2(){
        AttributesIcon aI2 = new AttributesIcon('HasSOXObject');
        system.assertEquals('HasSOXObject' , aI2.imageId);
        
        AttributesIcon aI3 = new AttributesIcon('HasIntegration');
        system.assertEquals('HasIntegration' , aI3.imageId);
        
        AttributesIcon aI4 = new AttributesIcon('HasManagedPackage');
        system.assertEquals('HasManagedPackage' , aI4.imageId);
        
        AttributesIcon aI5 = new AttributesIcon('HasHighImpact');
        system.assertEquals('HasHighImpact' , aI5.imageId);
        
        AttributesIcon aI6 = new AttributesIcon('HasDoubleDeployment');
        system.assertEquals('HasDoubleDeployment' , aI6.imageId);
        
        AttributesIcon aI7 = new AttributesIcon('HasDuplicateModCR');
        system.assertEquals('HasDuplicateModCR' , aI7.imageId);
        
        AttributesIcon aI8 = new AttributesIcon('HasDuplicateModRelease');
        system.assertEquals('HasDuplicateModRelease' , aI8.imageId);
    }
}