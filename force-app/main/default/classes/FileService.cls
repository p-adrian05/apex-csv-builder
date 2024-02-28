
public with sharing class FileService {
    /**
         * S—Document is located within Salesforce. Label is Salesforce.
        E—Document is located outside of Salesforce. Label is External.
        L—Document is located on a social network and accessed via Social Customer Service. Label is Social Customer Service
         */
    public enum FileLocation {
        S,
        E,
        L
    }
    /**
     * Attaches a base64 encoded document to a record.
     *
     * @param recordId The ID of the record to which the PDF will be attached.
     * @param base64Data The base64 encoded data of the file.
     * @param fileName The name of the file.
     * @param location The location where the file should be stored (e.g., FileLocation.S for Salesforce).
     * @return The ID of the newly created ContentDocumentLink.
     */
    public static ContentDocumentLink attachBase64FileToRecord(Id recordId, String base64Data, String fileName,FileLocation location) {
        Id documentId = createFile(EncodingUtil.base64Decode(base64Data), fileName, location);
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = documentId;
        contentDocumentLink.LinkedEntityId = recordId;
        contentDocumentLink.ShareType = 'I';
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;
        return contentDocumentLink;
    }
    /**
     * Creates a new file (Content Document) and associates it with a record.
     *
     * @param fileData The binary data of the file.
     * @param title The title of the file.
     * @param location The location where the file should be stored (e.g., FileLocation.S for Salesforce).
     * @return The ID of the newly created ContentDocument.
     */
    public static Id createFile(Blob fileData, String title,FileLocation location) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = location.name();
        cv.Title = title;
        cv.PathOnClient = title;
        cv.VersionData = fileData;
        insert cv;

        ContentDistribution cd = new ContentDistribution();
        cd.Name = cv.Title;
        cd.ContentVersionId = cv.Id;
        cd.PreferencesAllowOriginalDownload = true;
        cd.PreferencesAllowPDFDownload = true;
        cd.PreferencesAllowViewInBrowser = true;
        insert cd;
        List<ContentDistribution> cdList = [SELECT Id,ContentDocumentId FROM ContentDistribution WHERE Id =: cd.Id];
        return cdList[0].ContentDocumentId;
    }
    /**
 * Encodes file data using the specified encoding.
 *
 * @param fileData The original file data as a string.
 * @param encoding The desired encoding (e.g., 'UTF-8').
 * @return The encoded file data as a Blob.
 */
    public static Blob encodeFileData(String fileData, String encoding) {
        String urlEncoded = EncodingUtil.urlEncode(fileData, encoding);
        String[] chars = urlEncoded.replaceAll('\\+',' ').split('');
        for(Integer i = 0; i < chars.size(); i++) {
            if(chars[i] == '%') {
                chars[i] = EncodingUtil.convertToHex(EncodingUtil.convertFromHex(chars[i+1]+chars[i+2]));
                chars.remove(i+2);
                chars.remove(i+1);
            } else {
                chars[i] = EncodingUtil.convertToHex(Blob.valueOf(chars[i]));
            }
        }
        return EncodingUtil.convertFromHex(String.join(chars,''));
    }
    /**
     * Decodes a Blob of file data into a readable String using the provided encoding.
     *
     * @param fileData The Blob of file data to decode.
     * @param encoding The encoding to use for decoding the file data.
     * @return A String containing the decoded file data.
 */
    public static String decodeFileData(Blob fileData, String encoding){
        String hex = EncodingUtil.convertToHex(fileData);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), encoding);
    }
}