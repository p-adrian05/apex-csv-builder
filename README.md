Introduction
============

This Apex library provides a convenient way to generate CSV files in Salesforce. It includes several classes to handle different aspects of CSV generation, such as defining the headers, serializing records to CSV format, and creating a file in Salesforce.

## Defining Custom CSV Headers
You can define custom CSV headers with various attributes such as name, maximum length, type, default value, etc. Here's an example:
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
## Implementing Object-specific CSV Service
Extend the provided abstract __CSVService__ class using the __CSVFileService__ implementation to define your object-specific implementation.

Here's an example for the Contact object:
```java
public with sharing class ContactCSVService extends CSVService {

    private final static String FILE_NAME = 'contactCSV';
    private final static String FILE_EXTENSION = '.CSV';
    private final static String FILE_NAME_FULL = FILE_NAME + FILE_EXTENSION;
    private final static String ENCODING = FileService.ISO_8859_2;
    private final static List<CSVHeader> HEADERS = ContactCSVHeaders.getHeaders();

    public ContactCSVService(CSVFileService csvFileService) {
        super(csvFileService, HEADERS, FILE_NAME_FULL,ENCODING);
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
```
## Generating CSV File from Records
You can use the __createCSV__ method to generate a CSV file from records and receive the Content Document Id.

```java
ContactCSVService service = new ContactCSVService(new CSVFileService());
Id fileId = service.createCSV(contactIdList);
```
The Content Document Id can be used to:
- Download the file directly in Salesforce Lightning or in LWC with the following URL path: __/sfc/servlet.shepherd/document/download/'+documentId+'?operationContext=S1__
- Open the Record Page of the Document
- Navigate the user in LWC with NavigationMixin
Here's an example of navigating to the document in LWC:
```js
  viewDocument(documentId){
    this[NavigationMixin.GenerateUrl]({
        type: "standard__recordPage",
        attributes: {
            recordId: documentId,
            actionName: "view",
        },
    }).then(url => {
        window.open(url, "_blank");
    });
}
```