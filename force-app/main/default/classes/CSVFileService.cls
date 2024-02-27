
/**
 * CSVFileService is a class that provides methods for converting a list of SObjects to a CSV string.
 */
public with sharing class CSVFileService {
    /**
         * The errors map contains a set of records that have errors during the CSV conversion.
         * The key is the Id of the record and the value is a list of error messages.
         */
    private Map<Id,List<String>> errors = new Map<Id,List<String>>();
    /**
        * The serializeToCSV method converts a list of CSVHeader objects and a list of SObjects to a CSV string.
        *
        * @param csvHeaders The list of CSVHeader objects.
        * @param records The list of SObject records.
        * @return The CSV string.
        * @throws CSVFileException If there are any errors during the CSV conversion.
        */
    public String serializeToCSV(List<CSVHeader> csvHeaders, List<SObject> records){
        if(csvHeaders == null || csvHeaders.isEmpty()){
            throw new CSVFileException('csvHeaders is empty or null');
        }
        if(records != null){
            for(SObject record : records){
                for(CSVHeader header : csvHeaders){
                    Object value = getValue(header, record);
                    try{
                        header.addRow(value);
                    }catch (Exception e){
                        if(errors.containsKey(record.Id)){
                            errors.get(record.Id).add(e.getMessage());
                        }else{
                            errors.put(record.Id,new List<String>{e.getMessage()});
                        }
                    }
                }
            }
        }
        if(!errors.isEmpty()){
            String errorMessage = 'Error during CSV conversion!\n';
            for(Id recordId : errors.keySet()){
                errorMessage += ' - With record Id :'+recordId+'\n';
                List<String> recordErrors = errors.get(recordId);
                for(String error : recordErrors){
                    errorMessage += '   - '+error + '\n';
                }
            }
            throw new CSVFileException(errorMessage);
        }
        return serializeToCSV(csvHeaders);
    }
    /**
  * The getValue method retrieves the value of a field from an SObject record.
  * The field parameter specifies a dot notation path to the field's location within the SObject record.
  * If the field value is null and there is a default field name, the value of that field is used instead.
  * If the field is required and there is no value or default value, a CSVFileException is thrown.
  *
  * @param header The CSVHeader object.
  * @param record The SObject record.
  * @return The value of the specified field in the SObject record.
  * @throws CSVFileException If the field is required and there is no value or default value.
  */
    private Object getValue(CSVHeader header, SObject record){
        Object value;
        if(header.fieldName != null){
            value = getFieldValueFromSObject(header.fieldName, record);
            if(value == null && header.defaultValueFieldName != null){
                value = getFieldValueFromSObject(header.defaultValueFieldName, record);
            }
            if(header.required && value == null && header.defaultValue == null){
                throw new CSVFileException('Required field: '+header.fieldName+' is empty for header: ' + header.name);
            }
            if(value == null && header.defaultValue != null){
                value = header.defaultValue;
            }
        }else{
            value = header.defaultValue;
        }
        return value;
    }
    @TestVisible
    private static String serializeToCSV(List<CSVHeader> headers){
        String csv = '';
        Integer maxRowDepth = 0;
        for(CSVHeader header : headers){
            csv += header.name + ';';
            Integer rowDepth = header.getRows().size();
            if(rowDepth > maxRowDepth){
                maxRowDepth = rowDepth;
            }
        }
        csv = csv.removeEndIgnoreCase(';');
        csv += '\n';
        for(Integer i = 0; i < maxRowDepth; i++){
            for(CSVHeader header : headers){
                List<Object> rows = header.getRows();
                if(rows.size() > i){
                    csv += rows[i] + ';';
                }else{
                    csv += ';';
                }
            }
            csv = csv.removeEndIgnoreCase(';');
            csv += '\n';
        }
        return csv;
    }
    /**
    * Retrieves the value of a field from an SObject record. The field parameter specifies a dot notation path
    * to the field's location within the SObject record.

    * @param field The dot notation path to the field's location.
    * @param record The SObject record containing the field.
    * @return The value of the specified field in the SObject record.
    */
    @TestVisible
    private Object getFieldValueFromSObject(String field,SObject record){
        List<String> sourceRecordQueryFields = field.split('\\.');

        Object currentValueObject;
        SObject currentSObject = record;

        for(Integer i = 0; i<sourceRecordQueryFields.size();i++){
            if(currentSObject!=null){
                if(i == sourceRecordQueryFields.size()-1){
                    currentValueObject = currentSObject.get(sourceRecordQueryFields.get(i));
                }else{
                    currentSObject = currentSObject.getSObject(sourceRecordQueryFields.get(i));
                }
            }

        }
        return currentValueObject;
    }
    public class CSVFileException extends Exception{}

}