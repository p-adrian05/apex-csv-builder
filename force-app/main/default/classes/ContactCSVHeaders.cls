
public with sharing class ContactCSVHeaders {
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