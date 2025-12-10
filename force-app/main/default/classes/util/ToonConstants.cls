/**
 * Shared constants for TOON format encoding and decoding.
 */
public class ToonConstants {
    public static final String COLON = ':';
    public static final String SPACE = ' ';
    public static final String NEWLINE = '\n';
    public static final String DASH = '-';
    public static final String QUOTE = '"';
    public static final String BACKSLASH = '\\';
    public static final String COMMA = ',';
    public static final String TAB = '\t';
    public static final String PIPE = '|';
    
    public static final String ARRAY_START = '[';
    public static final String ARRAY_END = ']';
    public static final String OBJECT_START = '{';
    public static final String OBJECT_END = '}';
    
    public static final String LIST_ITEM_PREFIX = '- ';
    
    public static final String NULL_VALUE = 'null';
    public static final String TRUE_VALUE = 'true';
    public static final String FALSE_VALUE = 'false';
    
    public static final Pattern KEY_PATTERN = Pattern.compile('^[a-zA-Z_][a-zA-Z0-9_]*$');
    public static final Pattern NUMBER_PATTERN = Pattern.compile('^-?\\d+(\\.\\d+)?$');
    public static final Pattern BOOLEAN_PATTERN = Pattern.compile('^(true|false)$');
    public static final Pattern NULL_PATTERN = Pattern.compile('^null$');
}
