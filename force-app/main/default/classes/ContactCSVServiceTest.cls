

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

        ContactCSVService contactCSVService = new ContactCSVService(new CSVFileService());
        Id fileId = contactCSVService.createCSV(new List<Id>{contact.Id});

        List<ContentVersion>  cdList = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId];
        Assert.areEqual(1, cdList.size());
        String csvContentString = FileService.decodeFileData(cdList[0].VersionData, contactCSVService.encoding);
        System.debug(csvContentString);
        String expectedCsvContent = 'Account Name;First Name;Phone\n' +
                                    'Test Account;JOHN;122112211221';
        Assert.isTrue(csvContentString.contains(expectedCsvContent));
    }

}