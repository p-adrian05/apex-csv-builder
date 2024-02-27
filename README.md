Introduction
============

This Apex library provides a convenient way to generate CSV files in Salesforce. It includes several classes to handle different aspects of CSV generation, such as defining the headers, serializing records to CSV format, and creating a file in Salesforce.

Defining headers with custom name, maximum length, type, and default value and more.
```java
public class ContactCSVHeaders {
    private ContactCSVHeaders() {
    }
    public final static CSVHeader ACCOUNT_NAME_HEADER = new CSVHeader('Account Name', 50,
            CSVHeader.CSVType.ALPHANUMERIC, false, 'Account.Name');

    public final static  CSVHeader FIRST_NAME_HEADER = new CSVHeader('First Name', 50,
            CSVHeader.CSVType.ALPHANUMERIC, true, Contact.FirstName.getDescribe().getName())
            .setHeaderValueSerializer(new FirstNameSerializer());

    public final static  CSVHeader PHONE_HEADER = new CSVHeader('Phone', 44,
            CSVHeader.CSVType.NUM, true, Contact.Phone.getDescribe().getName())
            .setDefaultValue(111111111);

    public static List<CSVHeader> getHeaders() {
        return new List<CSVHeader>{
            ACCOUNT_NAME_HEADER,
                    FIRST_NAME_HEADER,
                    PHONE_HEADER
        };
    }
    public class FirstNameSerializer implements CSVHeader.HeaderValueSerializer {
        public Object serialize(Object value) {
            if(value instanceof String){
                return value.toString().toUpperCase();
            }
            return value;
        }
    }
}
```
Extend the provided abstract CSVService class using the CSVFileService implementation to define your object type specific implementation.

Here's an example:
```java
public with sharing class ContactCSVService extends CSVService {

    private final static String FILE_NAME = 'contactCSV';
    private final static String FILE_EXTENSION = '.CSV';
    private final static String FILE_NAME_FULL = FILE_NAME + FILE_EXTENSION;
    private final static List<CSVHeader> HEADERS = ContactCSVHeaders.getHeaders();

    public ContactCSVService(CSVFileService csvFileService) {
        super(csvFileService, HEADERS, FILE_NAME_FULL);
    }
    public override Id createKHCSV(List<Id> invoiceRecordIds) {
        List<Contact> records = getContacts(invoiceRecordIds);
        return super.createKHCSV(records);
    }
    private List<Contact> getContacts(List<Id> contactIds) {
        return [
                SELECT Id, Name,Account.Name, Phone, FirstName,LastName
                FROM Contact
                WHERE Id IN :contactIds
        ];
    }
}
```
Then you can use the createCSV method to generate CSV File from records.
```java
ContactCSVService service = new ContactCSVService(new CSVFileService());
Id fileId = service.createCSV(contactIdList);
```