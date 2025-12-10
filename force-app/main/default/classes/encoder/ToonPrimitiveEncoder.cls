/**
 * Encodes primitive values and keys for TOON format.
 * 
 * Handles encoding of primitives (null, boolean, number, string) and object keys
 * with proper quoting and escaping according to TOON specification.
 */
public class ToonPrimitiveEncoder {
    
    /**
     * Encode a primitive value.
     * 
     * @param value The primitive value to encode
     * @param delimiter The delimiter being used (affects quoting)
     * @return Encoded string representation
     */
    public static String encodePrimitive(Object value, String delimiter) {
        if (value == null) {
            return ToonConstants.NULL_VALUE;
        }
        
        if (value instanceof Boolean) {
            return encodeBoolean((Boolean) value);
        }
        
        if (value instanceof Integer || value instanceof Long) {
            return String.valueOf(value);
        }
        
        if (value instanceof Decimal || value instanceof Double) {
            return encodeNumber(value);
        }
        
        if (value instanceof String) {
            return encodeStringLiteral((String) value, delimiter);
        }
        
        throw new ToonEncodingException('Unsupported primitive type: ' + getTypeName(value));
    }
    
    /**
     * Encode a boolean value.
     *
     * @param value The boolean value to encode
     * @return String representation of the boolean ('true' or 'false')
     */
    private static String encodeBoolean(Boolean value) {
        return value ? ToonConstants.TRUE_VALUE : ToonConstants.FALSE_VALUE;
    }
    
    /**
     * Encode a number (Decimal or Double) with proper formatting.
     * Removes trailing zeros and unnecessary decimal points per TOON spec.
     * Examples: 1.500 -> "1.5", 1.0 -> "1", -0 -> "0"
     *
     * @param value The numeric value to encode (Decimal, Double, Integer, or Long)
     * @return String representation of the number with trailing zeros removed
     */
    private static String encodeNumber(Object value) {
        Decimal decimalValue;
        
        if (value instanceof Decimal) {
            decimalValue = (Decimal) value;
        } else if (value instanceof Double) {
            decimalValue = Decimal.valueOf((Double) value);
        } else if (value instanceof Integer) {
            return String.valueOf((Integer) value);
        } else if (value instanceof Long) {
            return String.valueOf((Long) value);
        } else {
            return String.valueOf(value);
        }
        
        // Handle -0 -> 0 per spec
        if (decimalValue == 0) {
            return '0';
        }
        
        // Use toPlainString to avoid scientific notation initially
        String plainString = decimalValue.toPlainString();
        
        // Strip trailing zeros and decimal point if not needed
        return stripTrailingZeros(plainString);
    }
    
    /**
     * Remove trailing zeros from decimal numbers per TOON canonical form.
     * Examples: "1.500" -> "1.5", "1.0" -> "1", "42" -> "42"
     *
     * @param numberString The number string to process
     * @return The number string with trailing zeros and unnecessary decimal point removed
     */
    private static String stripTrailingZeros(String numberString) {
        if (!numberString.contains('.')) {
            return numberString;
        }
        
        String result = numberString;
        
        // Remove trailing zeros after decimal point
        while (result.endsWith('0') && result.contains('.')) {
            result = result.substring(0, result.length() - 1);
        }
        
        // Remove decimal point if no fractional part remains
        if (result.endsWith('.')) {
            result = result.substring(0, result.length() - 1);
        }
        
        return result;
    }
    
    /**
     * Encode a string literal with proper quoting and escaping.
     * 
     * @param value The string to encode
     * @param delimiter The delimiter being used
     * @return Quoted and escaped string if needed, or unquoted if safe
     */
    public static String encodeStringLiteral(String value, String delimiter) {
        if (value == null) {
            return ToonConstants.NULL_VALUE;
        }
        
        if (ToonStringValidator.isSafeUnquoted(value, delimiter)) {
            return value;
        }
        
        String escaped = ToonStringEscaper.escape(value);
        return ToonConstants.QUOTE + escaped + ToonConstants.QUOTE;
    }
    
    /**
     * Encode an object key with proper quoting if needed.
     * 
     * @param key The key to encode
     * @return Quoted key if needed, or unquoted if valid identifier
     */
    public static String encodeKey(String key) {
        if (key == null) {
            throw new ToonEncodingException('Object keys cannot be null');
        }
        
        if (ToonStringValidator.isValidUnquotedKey(key)) {
            return key;
        }
        
        String escaped = ToonStringEscaper.escape(key);
        return ToonConstants.QUOTE + escaped + ToonConstants.QUOTE;
    }
    
    /**
     * Get the type name of an object for error messages.
     *
     * @param value The object to get the type name for
     * @return String representation of the object's type name
     */
    private static String getTypeName(Object value) {
        if (value == null) {
            return 'null';
        }
        
        String typeName = String.valueOf(value);
        if (typeName.contains('Class.')) {
            return typeName.substringAfter('Class.');
        }
        
        return typeName;
    }
}
