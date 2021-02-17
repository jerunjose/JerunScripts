@isTest
public class SingleFileUploadControllerTest {
    @testSetup static void testDataSetup(){
        ContentVersion cv=new Contentversion();
        cv.Title = 'sample content';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
    }

 	@istest static void testMethods(){
        ContentDocument cd = [SELECT id from ContentDocument LIMIT 1];
        Test.startTest();
        	SingleFileUploadController.deleteContentDocument(cd.Id);
        	// Exception scenario
            SingleFileUploadController.deleteContentDocument(cd.Id);
        Test.stopTest();
    }
}