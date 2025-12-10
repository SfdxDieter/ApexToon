/**
 * Decodes primitive values from TOON string representations.
 * 
 * Infers type from string format and returns appropriate Apex type.
 */
public class ToonPrimitiveDecoder {
    
    /**
     * Parse a string value to its appropriate type.
     * 
     * Type inference:
     * - "null" -> null
     * - "true"/"false" -> Boolean
     * - Numeric format -> Decimal or Long
     * - Quoted string -> String (unescaped)
     * - Everything else -> String
     * 
     * @param value The string to parse
     * @return Typed value
     */
    public static Object parse(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        
        String trimmed = value.trim();
        
        if (trimmed == 'null') {
            return null;
        }
        
        if (trimmed == 'true') {
            return true;
        }
        
        if (trimmed == 'false') {
            return false;
        }
        
        if (trimmed.startsWith('"')) {
            return parseQuotedString(trimmed);
        }
        
        if (isOctalNumber(trimmed)) {
            return trimmed;
        }
        
        Object numericValue = tryParseNumber(trimmed);
        if (numericValue != null) {
            return numericValue;
        }
        
        return trimmed;
    }
    
    /**
     * Parse a quoted string, removing quotes and unescaping.
     *
     * @param value The quoted string to parse
     * @return The unescaped string without quotes
     */
    private static String parseQuotedString(String value) {
        ToonStringEscaper.validateString(value);
        String withoutQuotes = ToonStringValidator.removeQuotes(value);
        return ToonStringEscaper.unescape(withoutQuotes);
    }
    
    /**
     * Check if value looks like octal number (leading zeros).
     * These should be treated as strings to avoid confusion.
     *
     * @param value The string value to check
     * @return True if the value appears to be an octal number, false otherwise
     */
    private static Boolean isOctalNumber(String value) {
        if (!value.startsWith('0') && !value.startsWith('-0')) {
            return false;
        }
        
        Pattern octalPattern = Pattern.compile('^-?0+[0-7].*');
        if (!octalPattern.matcher(value).matches()) {
            return false;
        }
        
        Pattern zeroPattern = Pattern.compile('^-?0+(\\.0+)?([eE][+-]?\\d+)?$');
        if (zeroPattern.matcher(value).matches()) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Try to parse value as a number.
     * Returns null if not a valid number.
     *
     * @param value The string value to parse as a number
     * @return Decimal or Long if valid number, null otherwise
     */
    private static Object tryParseNumber(String value) {
        try {
            if (value.contains('.') || value.containsIgnoreCase('e')) {
                Decimal parsed = Decimal.valueOf(value);
                
                if (parsed == 0) {
                    return 0;
                }
                
                if (parsed.scale() == 0) {
                    return parsed.longValue();
                }
                
                return parsed;
            } else {
                return Long.valueOf(value);
            }
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * Parse a delimited string of values into a list.
     * Handles quoted values and escape sequences.
     * 
     * @param input The delimited string
     * @param delimiter The delimiter character
     * @return List of parsed values
     */
    public static List<Object> parseDelimitedValues(String input, String delimiter) {
        if (String.isBlank(input)) {
            return new List<Object>();
        }
        
        List<String> rawValues = splitRespectingQuotes(input, delimiter);
        List<Object> result = new List<Object>();
        
        for (String rawValue : rawValues) {
            result.add(parse(rawValue.trim()));
        }
        
        return result;
    }
    
    /**
     * Split string by delimiter while respecting quoted sections.
     *
     * @param input The string to split
     * @param delimiter The delimiter character to split by
     * @return List of string segments split by delimiter, preserving quoted content
     */
    private static List<String> splitRespectingQuotes(String input, String delimiter) {
        List<String> result = new List<String>();
        String current = '';
        Boolean inQuotes = false;
        Boolean escaped = false;
        
        for (Integer i = 0; i < input.length(); i++) {
            String chr = input.substring(i, i + 1);
            
            if (escaped) {
                current += chr;
                escaped = false;
            } else if (chr == '\\') {
                current += chr;
                escaped = true;
            } else if (chr == '"') {
                current += chr;
                inQuotes = !inQuotes;
            } else if (chr == delimiter && !inQuotes) {
                result.add(current);
                current = '';
                
                while (i + 1 < input.length() && input.substring(i + 1, i + 2) == ' ') {
                    i++;
                }
            } else {
                current += chr;
            }
        }
        
        if (current.length() > 0 || input.endsWith(delimiter)) {
            result.add(current);
        }
        
        return result;
    }
}
