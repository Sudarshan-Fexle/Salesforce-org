/**
    Desription      :   This class is used to store the encryption helper methods for site functionality (ie: EAB.com/Advisory.com).
  
    Created By      :   Victor Hanson
  
    Created Date    :   07/29/2014
  
    Revision Logs   :   v1 - Created
 **/ 
public class EncryptionHelper {
    
    // Convert the Advisory User data to JSON and Encrypt using AES256 w/private key
    public static String encrypt(SiteUser sUser) {
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(JSON.serialize(sUser, true)));
        return EncodingUtil.base64Encode(encryptedBlob);
    }
    
    // decrypt an AES256 encoded string and return the results
    public static String decrypt(blob encryptedBlob) {
        // decrypt the string in to a blob using our private KEY
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', SiteControllerHelper.KEY, encryptedBlob);
        return decryptedData.toString();
    }
    
    // encrypt a single String
    public static String encryptString(String origData) {
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        return EncodingUtil.base64Encode(encryptedBlob);
    }
    
    public static SiteUser deserializeSiteUser(String requestString) {
        // escape all single quotes
        return (SiteUser)JSON.deserialize(requestString, SiteUser.class);
    }
}