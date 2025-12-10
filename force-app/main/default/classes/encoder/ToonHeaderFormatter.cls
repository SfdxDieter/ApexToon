/**
 * Formats array and tabular headers for TOON format.
 * 
 * Handles generation of array headers with delimiters and field lists for tabular format.
 */
public class ToonHeaderFormatter {
    
    /**
     * Format an array header per TOON spec.
     * 
     * Per spec: delimiter symbol is included in brackets ONLY when it's NOT comma.
     * Comma is the default and is omitted from the bracket segment.
     * 
     * Examples:
     *   format(3, 'tags', null, ',') -> 'tags[3]:'
     *   format(2, 'items', ['id','name'], ',') -> 'items[2]{id,name}:'
     *   format(3, null, null, '\t') -> '[3\t]:'  (tab explicitly shown)
     *   format(3, null, null, '|') -> '[3|]:'   (pipe explicitly shown)
     * 
     * @param length Number of items in array
     * @param key Optional key/prefix (null for standalone array)
     * @param fields Optional field list for tabular format
     * @param delimiter The delimiter character
     * @return Formatted header string
     */
    public static String format(Integer length, String key, List<String> fields, String delimiter) {
        List<String> parts = new List<String>();
        
        if (key != null) {
            parts.add(ToonPrimitiveEncoder.encodeKey(key));
        }
        
        String lengthPart = '[' + String.valueOf(length);
        
        // Per TOON spec: only include delimiter symbol when NOT comma
        // Comma is the default and omitted from bracket segment
        if (!delimiter.equals(ToonConstants.COMMA)) {
            lengthPart += delimiter;
        }
        
        lengthPart += ']';
        parts.add(lengthPart);
        
        if (fields != null && !fields.isEmpty()) {
            String fieldsPart = formatFieldsList(fields, delimiter);
            parts.add(fieldsPart);
        }
        
        parts.add(':');
        
        return String.join(parts, '');
    }
    
    /**
     * Format the fields list for tabular format.
     * Example: ['id', 'name', 'age'] with ',' -> '{id,name,age}'
     *
     * @param fields The list of field names
     * @param delimiter The delimiter character
     * @return Formatted fields string enclosed in braces
     */
    private static String formatFieldsList(List<String> fields, String delimiter) {
        List<String> encodedFields = new List<String>();
        
        for (String field : fields) {
            encodedFields.add(ToonPrimitiveEncoder.encodeKey(field));
        }
        
        return '{' + String.join(encodedFields, delimiter) + '}';
    }
    
    /**
     * Format a simple inline array header (primitive values).
     * 
     * @param key Optional key
     * @param length Array length
     * @param options Encoding options
     * @return Formatted header
     */
    public static String formatInlineHeader(String key, Integer length, EncodeOptions options) {
        return format(
            length,
            key,
            null,
            options.getDelimiterString()
        );
    }
    
    /**
     * Format a tabular array header (array of objects with uniform fields).
     * 
     * @param key Optional key
     * @param length Array length
     * @param fields List of field names
     * @param options Encoding options
     * @return Formatted header
     */
    public static String formatTabularHeader(String key, Integer length, List<String> fields, EncodeOptions options) {
        return format(
            length,
            key,
            fields,
            options.getDelimiterString()
        );
    }
}
