

public with sharing class ContactCSVService extends CSVService {

    private final static String FILE_NAME = 'contactCSV';
    private final static String FILE_EXTENSION = '.CSV';
    private final static String FILE_NAME_FULL = FILE_NAME + FILE_EXTENSION;
    private final static List<CSVHeader> HEADERS = ContactCSVHeaders.getHeaders();

    public ContactCSVService(CSVFileService csvFileService) {
        super(csvFileService, HEADERS, FILE_NAME_FULL);
    }
    public override Id createCSV(List<Id> contactIds) {
        List<Contact> records = getContacts(contactIds);
        return super.createCSV(records);
    }
    private List<Contact> getContacts(List<Id> contactIds) {
        return [
                SELECT Id, Name,Account.Name, Phone, FirstName,LastName
                FROM Contact
                WHERE Id IN :contactIds
        ];
    }
}