/**
 * Utility class for escaping and unescaping strings in TOON format.
 */
public class ToonStringEscaper {
    
    /**
     * Escape special characters in a string value.
     * @param value The string to escape
     * @return The escaped string, or null if input is null
     */
    public static String escape(String value) {
        if (value == null) {
            return null;
        }
        
        String result = value;
        result = result.replace('\\', '\\\\');
        result = result.replace('"', '\\"');
        result = result.replace('\n', '\\n');
        result = result.replace('\r', '\\r');
        result = result.replace('\t', '\\t');
        
        return result;
    }
    
    /**
     * Unescape special characters in a string value.
     * @param value The string to unescape
     * @return The unescaped string, or null if input is null
     */
    public static String unescape(String value) {
        if (value == null) {
            return null;
        }
        
        String result = value;
        result = result.replace('\\n', '\n');
        result = result.replace('\\r', '\r');
        result = result.replace('\\t', '\t');
        result = result.replace('\\"', '"');
        result = result.replace('\\\\', '\\');
        
        return result;
    }
    
    /**
     * Validate that a quoted string is properly formatted.
     * Throws ToonException if the string has mismatched quotes.
     * @param value The string to validate
     */
    public static void validateString(String value) {
        if (value == null) {
            return;
        }
        
        if (value.startsWith('"') && !value.endsWith('"')) {
            throw new ToonException('Unterminated quoted string: ' + value);
        }
        
        if (!value.startsWith('"') && value.endsWith('"')) {
            throw new ToonException('Invalid quoted string: ' + value);
        }
        
        Integer quoteCount = 0;
        Boolean escaped = false;
        
        for (Integer i = 0; i < value.length(); i++) {
            String chr = value.substring(i, i + 1);
            
            if (escaped) {
                escaped = false;
                continue;
            }
            
            if (chr == '\\') {
                escaped = true;
            } else if (chr == '"') {
                quoteCount++;
            }
        }
        
        if (quoteCount > 0 && Math.mod(quoteCount, 2) != 0) {
            throw new ToonException('Mismatched quotes in string: ' + value);
        }
    }
}
