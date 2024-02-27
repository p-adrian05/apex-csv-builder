
@IsTest
private class CSVFileServiceTest {

    @IsTest
    static void testSerializeToCSV() {
        List<CSVHeader> headers = new List<CSVHeader>();
        List<SObject> records = new List<SObject>();
        //Parent relationship
        CSVHeader accountNameHeader = new CSVHeader('Account Name', 50, CSVHeader.CSVType.ALPHANUMERIC, false, 'Account.Name');
        //Required field
        CSVHeader firstNameHeader = new CSVHeader('First Name', 50, CSVHeader.CSVType.ALPHANUMERIC, true, Contact.FirstName.getDescribe().getName());
        //Required field with default value
        CSVHeader phoneHeader = new CSVHeader('Phone', 44, CSVHeader.CSVType.NUM, true, Contact.Phone.getDescribe().getName())
                .setDefaultValue(111111111);
        //Non-required field with default value
        CSVHeader lastNameHeader = new CSVHeader('Last Name', 44, CSVHeader.CSVType.ALPHANUMERIC, false, Contact.LastName.getDescribe().getName())
                .setDefaultValue(' ');
        //Always default value
        CSVHeader defaultHeader = new CSVHeader('Default', 44, CSVHeader.CSVType.ALPHANUMERIC, true, null)
                .setDefaultValue('default');
        //Default value from another field
        CSVHeader emailHeader = new CSVHeader('Email', 44, CSVHeader.CSVType.ALPHANUMERIC, false, Contact.Email.getDescribe().getName())
                .defaultValueFieldName(Contact.Phone.getDescribe().getName())
                .setDefaultValue('default email');

        headers.add(accountNameHeader);
        headers.add(firstNameHeader);
        headers.add(phoneHeader);
        headers.add(lastNameHeader);
        headers.add(defaultHeader);
        headers.add(emailHeader);

        Account account = new Account(Name = 'Test Account');
        Contact contact1 = new Contact(FirstName = 'John', Phone = '12323', LastName = 'Doe', Account = account, Email = 'email@test.com');
        Contact contact2 = new Contact(FirstName = 'Jane', Phone = '321321', LastName = 'John');
        Contact contact3 = new Contact(FirstName = 'Mark');
        Contact contact4 = new Contact(FirstName = 'Mark2', Phone = '321321');
        records.add(contact1);
        records.add(contact2);
        records.add(contact3);
        records.add(contact4);

        CSVFileService csvFileService = new CSVFileService();
        String csv = csvFileService.serializeToCSV(headers, records);

        System.debug(csv);
        String expectedCsv = 'Account Name;First Name;Phone;Last Name;Default;Email\nTest Account;John;12323;Doe;default;' +
                'email@test.com\nnull;Jane;321321;John;default;321321\nnull;Mark;111111111; ;default;default email\nnull;Mark2;321321; ;default;321321\n';
        Assert.areEqual(expectedCsv, csv);
    }

    @IsTest
    static void testSerializeToCSV_RequiredFieldMissing() {
        List<CSVHeader> headers = new List<CSVHeader>();
        List<SObject> records = new List<SObject>();

        CSVHeader firstNameHeader = new CSVHeader('First Name', 50, CSVHeader.CSVType.ALPHANUMERIC, true, Contact.FirstName.getDescribe().getName());
        CSVHeader phoneHeader = new CSVHeader('Phone', 44, CSVHeader.CSVType.NUM, true, Contact.Phone.getDescribe().getName());
        headers.add(firstNameHeader);
        headers.add(phoneHeader);

        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe');
        Contact contact2 = new Contact(FirstName = 'Jane', Phone = '321321');
        records.add(contact1);
        records.add(contact2);

        try {
            CSVFileService csvFileService = new CSVFileService();
            String csv = csvFileService.serializeToCSV(headers, records);
            Assert.fail('Should have thrown an exception when required field is missing');
        } catch (Exception e) {
        }
    }
    @IsTest
    static void testSerializeToCSV_EmptyRowsWithNullRecords() {
        List<CSVHeader> headers = new List<CSVHeader>();
        List<SObject> records = new List<SObject>();

        //Required field
        CSVHeader firstNameHeader = new CSVHeader('First Name', 50, CSVHeader.CSVType.ALPHANUMERIC, true, Contact.FirstName.getDescribe().getName());
        //Required field with default value
        CSVHeader phoneHeader = new CSVHeader('Phone', 44, CSVHeader.CSVType.NUM, true, Contact.Phone.getDescribe().getName())
                .setDefaultValue(111111111);
        //Non-required field with default value
        CSVHeader lastNameHeader = new CSVHeader('Last Name', 44, CSVHeader.CSVType.ALPHANUMERIC, false, Contact.LastName.getDescribe().getName())
                .setDefaultValue(' ');
        headers.add(firstNameHeader);
        headers.add(phoneHeader);
        headers.add(lastNameHeader);

        CSVFileService csvFileService = new CSVFileService();
        String csv = csvFileService.serializeToCSV(headers, null);

        System.debug(csv);
        String expectedCsv = 'First Name;Phone;Last Name\n';
        Assert.areEqual(expectedCsv, csv);
    }
    @IsTest
    static void testSerializeToCSV_NonRequiredFieldIsNull() {
        List<CSVHeader> headers = new List<CSVHeader>();
        List<SObject> records = new List<SObject>();

        //Required field
        CSVHeader firstNameHeader = new CSVHeader('First Name', 50, CSVHeader.CSVType.ALPHANUMERIC, true, Contact.FirstName.getDescribe().getName());
        //Required field with default value
        CSVHeader phoneHeader = new CSVHeader('Phone', 44, CSVHeader.CSVType.NUM, true, Contact.Phone.getDescribe().getName())
                .setDefaultValue(111111111);
        //Non-required field with null value
        CSVHeader lastNameHeader = new CSVHeader('Last Name', 44, CSVHeader.CSVType.ALPHANUMERIC, false, Contact.LastName.getDescribe().getName());
        headers.add(firstNameHeader);
        headers.add(phoneHeader);
        headers.add(lastNameHeader);
        Contact contact1 = new Contact(FirstName = 'Jane', Phone = '321321');
        records.add(contact1);

        CSVFileService csvFileService = new CSVFileService();
        String csv = csvFileService.serializeToCSV(headers, records);

        System.debug(csv);
        String expectedCsv = 'First Name;Phone;Last Name\nJane;321321;null\n';
        Assert.areEqual(expectedCsv, csv);
    }
    @IsTest
    static void testSerializeToCSV_FieldHeaderMapIsNull() {
        List<SObject> records = new List<SObject>();
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe');
        Contact contact2 = new Contact(FirstName = 'Jane', Phone = '321321');
        records.add(contact1);
        records.add(contact2);

        try {
            CSVFileService csvFileService = new CSVFileService();
            String csv = csvFileService.serializeToCSV(null, records);
            Assert.fail('Should have thrown an exception when FieldHeaderMap is null');
        } catch (Exception e) {
        }
    }
}