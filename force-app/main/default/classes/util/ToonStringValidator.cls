/**
 * Utility class for validating strings and keys in TOON format.
 */
public class ToonStringValidator {
    
    private static final Set<String> RESERVED_WORDS = new Set<String>{
        'null', 'true', 'false'
    };
    
    /**
     * Check if a string value can be safely written without quotes.
     * 
     * A value needs quotes if it:
     * - Contains the delimiter
     * - Is a reserved word (null, true, false)
     * - Looks like a number
     * - Has leading/trailing whitespace
     * - Contains special characters like newlines or quotes
     *
     * @param value The string value to check
     * @param delimiter The delimiter character being used
     * @return True if the value can be written without quotes
     */
    public static Boolean isSafeUnquoted(String value, String delimiter) {
        if (String.isBlank(value)) {
            return false;
        }
        
        if (value != value.trim()) {
            return false;
        }
        
        if (RESERVED_WORDS.contains(value.toLowerCase())) {
            return false;
        }
        
        if (ToonConstants.NUMBER_PATTERN.matcher(value).matches()) {
            return false;
        }
        
        if (value.contains(delimiter)) {
            return false;
        }
        
        if (value.contains('"') || value.contains('\\') || 
            value.contains('\n') || value.contains('\r') || value.contains('\t')) {
            return false;
        }
        
        if (value.contains(':') || value.contains('[') || value.contains(']') ||
            value.contains('{') || value.contains('}')) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Check if a key can be written without quotes.
     * 
     * Keys must start with a letter or underscore and contain only
     * letters, numbers, and underscores to be unquoted.
     *
     * @param key The key to validate
     * @return True if the key can be written without quotes
     */
    public static Boolean isValidUnquotedKey(String key) {
        if (String.isBlank(key)) {
            return false;
        }
        
        return ToonConstants.KEY_PATTERN.matcher(key).matches();
    }
    
    /**
     * Remove surrounding quotes from a string if present.
     *
     * @param value The string to process
     * @return The string without surrounding quotes, or unchanged if no quotes
     */
    public static String removeQuotes(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        
        if (value.startsWith('"') && value.endsWith('"') && value.length() >= 2) {
            return value.substring(1, value.length() - 1);
        }
        
        return value;
    }
}
