/**
 * CSVHeader is a class that represents a header in a CSV file.
 * It contains the necessary information to validate and serialize the values of the header.
 */
public with sharing class CSVHeader {
    public final String name {get;private set;}
    public final Integer maxLength {get;private set;}
    public final CSVType type {get;private set;}
    public final Boolean required {get;private set;}
    public final String fieldName {get;private set;}
    public Object defaultValue {get;private set;}
    public String defaultValueFieldName {get;private set;}
    private HeaderValueSerializer headerValueSerializer;
    private final List<Object> rows;

    public CSVHeader(String name, Integer maxLength, CSVType type, Boolean required, String fieldName) {
        this.name = name;
        this.maxLength = maxLength;
        this.type = type;
        this.required = required;
        this.rows = new List<Object>();
        this.fieldName = fieldName;
    }
    public CSVHeader setDefaultValue(Object defaultValue) {
        this.defaultValue = defaultValue;
        return this;
    }

    public CSVHeader defaultValueFieldName(String defaultValueFieldName) {
        this.defaultValueFieldName = defaultValueFieldName;
        return this;
    }
    public CSVHeader setHeaderValueSerializer(HeaderValueSerializer serializer) {
        this.headerValueSerializer = serializer;
        return this;
    }

    public void addRow(Object row) {
        if(this.headerValueSerializer != null && row !=null) {
            row = this.headerValueSerializer.serialize(row);
        }
        if (this.maxLength != null && row != null && String.valueOf(row).length() > this.maxLength) {
            throw new CSVFileService.CSVFileException('The value "'+row+'" for the column "' + this.name + '" is too long. ' +
                    'The max length is ' + this.maxLength+ ' characters.');
        }
        this.rows.add(row);
    }
    public List<Object> getRows() {
        return this.rows.clone();
    }

    public enum CSVType {
        NUM,
        ALPHANUMERIC
    }

    public interface HeaderValueSerializer {
        Object serialize(Object value);
    }
}