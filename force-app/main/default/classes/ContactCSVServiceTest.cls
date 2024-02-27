

@IsTest
private class ContactCSVServiceTest {
    @IsTest
    static void testCreateKHCSV() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.FirstName = 'John';
        contact.LastName = 'Doe';
        contact.Email = 'test@test.com';
        contact.Phone = '122112211221';
        insert contact;

        ContactCSVService service = new ContactCSVService(new CSVFileService());
        Id fileId = service.createCSV(new List<Id>{contact.Id});

        List<ContentVersion>  cdList = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId];
        Assert.areEqual(1, cdList.size());
        String csvContentString = blobToString(cdList[0].VersionData, 'ISO-8859-2');
        System.debug(csvContentString);
        String expectedCsvContent = 'Account Name;First Name;Phone\n' +
                                    'Test Account;JOHN;122112211221';
        Assert.isTrue(csvContentString.contains(expectedCsvContent));
    }
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

}