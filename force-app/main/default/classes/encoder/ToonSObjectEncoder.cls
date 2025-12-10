/**
 * Encoder for Salesforce SObjects with explicit field selection.
 * 
 * Provides specialized encoding for SObjects with:
 * - Explicit field selection via SObjectField or field names
 * - Relationship field support (dot notation)
 * - Field-level security filtering
 * - Tabular format for uniform records
 */
public class ToonSObjectEncoder {
    
    /**
     * Encode SObjects with explicit field selection using SObjectField.
     *
     * @param records The list of SObject records to encode
     * @param fields The list of SObjectField to include in encoding
     * @param options Encoding options
     * @return TOON-formatted string representation of the SObjects
     */
    public static String encodeSObjects(List<SObject> records, List<Schema.SObjectField> fields, EncodeOptions options) {
        if (records == null || records.isEmpty()) {
            return '[0]:';
        }
        
        Schema.SObjectType recordType = records[0].getSObjectType();
        validateSameType(records, recordType);
        
        List<Object> mappedRecords = new List<Object>();
        for (SObject record : records) {
            Map<String, Object> mapped = sObjectToMap(record, fields);
            if (!mapped.isEmpty()) {
                mappedRecords.add(mapped);
            }
        }
        
        return encodeSObjectsWithType(mappedRecords, recordType, options);
    }
    
    /**
     * Encode SObjects with field names (supports relationships via dot notation).
     *
     * @param records The list of SObject records to encode
     * @param fieldNames The list of field name strings (supports dot notation for relationships)
     * @param options Encoding options
     * @return TOON-formatted string representation of the SObjects
     */
    public static String encodeSObjects(List<SObject> records, List<String> fieldNames, EncodeOptions options) {
        if (records == null || records.isEmpty()) {
            return '[0]:';
        }
        
        Schema.SObjectType recordType = records[0].getSObjectType();
        validateSameType(records, recordType);
        
        List<Object> mappedRecords = new List<Object>();
        for (SObject record : records) {
            Map<String, Object> mapped = sObjectToMapByFieldNames(record, fieldNames);
            if (!mapped.isEmpty()) {
                mappedRecords.add(mapped);
            }
        }
        
        return encodeSObjectsWithType(mappedRecords, recordType, options);
    }
    
    /**
     * Encode SObjects with type metadata included.
     * Wraps the encoded records with SObject type information.
     *
     * @param mappedRecords The list of mapped records to encode
     * @param sObjectType The SObject type metadata
     * @param options Encoding options
     * @return TOON-formatted string with type metadata
     */
    private static String encodeSObjectsWithType(List<Object> mappedRecords, Schema.SObjectType sObjectType, EncodeOptions options) {
        String sObjectName = sObjectType.getDescribe().getName();
        
        Map<String, Object> wrapper = new Map<String, Object>();
        wrapper.put('__sObjectType', sObjectName);
        wrapper.put('records', mappedRecords);
        
        return ApexToon.encode(wrapper, options);
    }
    
    /**
     * Convert SObject to Map using SObjectField list.
     *
     * @param record The SObject record to convert
     * @param fields The list of SObjectField to include
     * @return Map representation of the SObject with selected fields
     */
    public static Map<String, Object> sObjectToMap(SObject record, List<Schema.SObjectField> fields) {
        Map<String, Object> result = new Map<String, Object>();
        
        if (record == null || fields == null || fields.isEmpty()) {
            return result;
        }
        
        for (Schema.SObjectField field : fields) {
            String fieldName = field.getDescribe().getName();
            Object value = record.get(field);
            
            if (value == null) {
                continue;
            }
            
            result.put(fieldName, normalizeFieldValue(value));
        }
        
        return result;
    }
    
    /**
     * Convert SObject to Map using field name strings (supports relationships).
     *
     * @param record The SObject record to convert
     * @param fieldNames The list of field names (supports dot notation for relationships)
     * @return Map representation of the SObject with selected fields
     */
    public static Map<String, Object> sObjectToMapByFieldNames(SObject record, List<String> fieldNames) {
        Map<String, Object> result = new Map<String, Object>();
        
        if (record == null || fieldNames == null || fieldNames.isEmpty()) {
            return result;
        }
        
        for (String fieldName : fieldNames) {
            Object value = getFieldValue(record, fieldName);
            
            if (value == null) {
                continue;
            }
            
            result.put(fieldName, normalizeFieldValue(value));
        }
        
        return result;
    }
    
    /**
     * Get field value supporting dot notation for relationships.
     *
     * @param record The SObject record to extract value from
     * @param fieldPath The field path (supports dot notation for relationships)
     * @return The field value, or null if not found
     */
    private static Object getFieldValue(SObject record, String fieldPath) {
        if (!fieldPath.contains('.')) {
            return record.get(fieldPath);
        }
        
        List<String> parts = fieldPath.split('\\.');
        SObject current = record;
        
        for (Integer i = 0; i < parts.size() - 1; i++) {
            current = current.getSObject(parts[i]);
            if (current == null) {
                return null;
            }
        }
        
        return current.get(parts[parts.size() - 1]);
    }
    
    /**
     * Normalize field values for TOON encoding.
     *
     * @param value The field value to normalize
     * @return Normalized value suitable for TOON encoding
     */
    private static Object normalizeFieldValue(Object value) {
        if (value == null) {
            return null;
        }
        
        if (value instanceof Date) {
            return ((Date) value).format();
        }
        
        if (value instanceof DateTime) {
            return ((DateTime) value).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        
        if (value instanceof Time) {
            return String.valueOf(value);
        }
        
        if (value instanceof List<SObject>) {
            String jsonStr = JSON.serialize(value);
            return JSON.deserializeUntyped(jsonStr);
        }
        
        return value;
    }
    
    /**
     * Validate all records are same SObject type.
     *
     * @param records The list of SObject records to validate
     * @param expectedType The expected SObject type
     */
    private static void validateSameType(List<SObject> records, Schema.SObjectType expectedType) {
        for (SObject record : records) {
            if (record.getSObjectType() != expectedType) {
                throw new ToonEncodingException(
                    'Mixed SObject types not supported. Expected: ' + expectedType.getDescribe().getName() +
                    ', Found: ' + record.getSObjectType().getDescribe().getName()
                );
            }
        }
    }
    
    /**
     * Get all accessible fields for an SObject type.
     *
     * @param sObjectType The SObject type to get fields for
     * @return List of accessible SObjectField instances
     */
    public static List<Schema.SObjectField> getAccessibleFields(Schema.SObjectType sObjectType) {
        List<Schema.SObjectField> accessibleFields = new List<Schema.SObjectField>();
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            if (fieldDescribe.isAccessible()) {
                accessibleFields.add(field);
            }
        }
        
        return accessibleFields;
    }
}
