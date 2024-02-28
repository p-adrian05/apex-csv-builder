/**
 * CSVService is an abstract class that provides a base for creating CSV files from a list of records.
 */
public with sharing abstract class CSVService {
    /**
        * The CSVServiceExecutable interface defines a method that takes the list of records from which the CSV file is generated
        * and you can define modifications on these records, like update a status field that is related with the CSV generation.
        * Executed after the CSV File is crated.
        */
    public interface CSVServiceExecutable {
        List<SObject> execute(List<SObject> records);
    }

    protected final CSVFileService csvFileService;
    protected final List<CSVHeader> headers;
    protected final String fileName;
    protected final String encoding;

    public CSVService(CSVFileService csvFileService, List<CSVHeader> headers, String fileName,String encoding) {
        this.csvFileService = csvFileService;
        this.headers = headers;
        this.fileName = fileName;
        this.encoding = encoding;
    }
    /**
     * The createKHCSV method serializes the records to a CSV string using the csvFileService and creates a new file with the CSV data.
     *
     * @param records The list of records to serialize.
     * @return The Id of the new file.
     */
    public virtual Id createCSV(List<SObject> records) {
        String csvString = csvFileService.serializeToCSV(headers, records);
        return createFile(csvString, fileName,encoding);
    }
    /**
      * The createKHCSV method serializes the records to a CSV string using the csvFileService, creates a new file with the CSV data,
      * and then execute the provided CSVServiceExecutable instance execute method
      *
      * @param records The list of records to serialize.
      * @param executable The CSVServiceExecutable to modify the records.
      * @return The Id of the new file.
      */
    public virtual Id createCSV(List<SObject> records,CSVServiceExecutable executable) {
        Id documentId = createCSV(records);
        executable.execute(records);
        return documentId;
    }
    public abstract Id createCSV(List<Id> records);
    /**
     * Creates a new file with the provided CSV data and encoding.
     *
     * @param fileData The CSV data to add to the file.
     * @param title The name of the file.
     * @param encoding The encoding to use for the file.
     * @return The Id of the new file.
     */
    protected virtual Id createFile(String fileData, String title,String encoding) {
        Blob body = FileService.encodeFileData(fileData, encoding);
        return FileService.createFile(body,title,FileService.FileLocation.S);
    }
}