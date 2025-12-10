/**
 * Parser for TOON format strings.
 * 
 * Manages line-by-line parsing state and provides methods for
 * extracting structure from indented TOON format.
 */
public class ToonParser {
    private List<String> lines;
    private Integer currentLine;
    private DecodeOptions options;
    private String delimiter;
    private Integer indentSize;
    
    public ToonParser(String toon, DecodeOptions options) {
        this.lines = toon.split('\n');
        this.currentLine = 0;
        this.options = options != null ? options : new DecodeOptions();
        this.delimiter = ',';
        this.indentSize = detectIndentSize();
    }
    
    /**
     * Auto-detect indent size from the first indented line.
     */
    private Integer detectIndentSize() {
        for (String line : lines) {
            if (String.isBlank(line)) {
                continue;
            }
            Integer leadingSpaces = 0;
            for (Integer i = 0; i < line.length(); i++) {
                if (line.substring(i, i + 1) == ' ') {
                    leadingSpaces++;
                } else {
                    break;
                }
            }
            if (leadingSpaces > 0) {
                return leadingSpaces;
            }
        }
        return 2; // Default to 2 if no indented lines found
    }
    
    /**
     * Get indentation depth of a line.
     */
    public Integer getDepth(String line) {
        if (String.isBlank(line)) {
            return 0;
        }
        
        if (options.strictMode && line.startsWith('\t')) {
            throw new ToonDecodingException('Tab character in indentation');
        }
        
        Integer leadingSpaces = 0;
        for (Integer i = 0; i < line.length(); i++) {
            if (line.substring(i, i + 1) == ' ') {
                leadingSpaces++;
            } else {
                break;
            }
        }
        
        Integer depth = leadingSpaces / indentSize;
        
        if (options.strictMode && Math.mod(leadingSpaces, indentSize) != 0) {
            throw new ToonDecodingException('Non-multiple indentation at line ' + currentLine);
        }
        
        return depth;
    }
    
    /**
     * Find index of unquoted colon in a string.
     * Returns -1 if not found.
     */
    public Integer findUnquotedColon(String content) {
        Boolean inQuotes = false;
        Boolean escaped = false;
        
        for (Integer i = 0; i < content.length(); i++) {
            String chr = content.substring(i, i + 1);
            
            if (escaped) {
                escaped = false;
                continue;
            }
            
            if (chr == '\\') {
                escaped = true;
            } else if (chr == '"') {
                inQuotes = !inQuotes;
            } else if (chr == ':' && !inQuotes) {
                return i;
            }
        }
        
        return -1;
    }
    
    /**
     * Check if line starts with array header pattern.
     */
    public Boolean isArrayHeader(String content) {
        return content.trim().startsWith('[');
    }
    
    /**
     * Check if line is a keyed array (e.g. "tags[3]:").
     */
    public Boolean isKeyedArray(String content) {
        Integer bracketIdx = content.indexOf('[');
        if (bracketIdx <= 0) {
            return false;
        }
        
        Integer closeBracketIdx = content.indexOf(']', bracketIdx);
        if (closeBracketIdx < 0) {
            return false;
        }
        
        Integer colonIdx = findUnquotedColon(content);
        return colonIdx > closeBracketIdx;
    }
    
    /**
     * Extract delimiter from array header.
     * Checks for \t or | after the length.
     *
     * @param header The array header string
     * @return The delimiter character (comma by default)
     */
    public String extractDelimiterFromHeader(String header) {
        Integer openBracket = header.indexOf('[');
        Integer closeBracket = header.indexOf(']');
        
        if (openBracket < 0 || closeBracket < 0) {
            return ',';
        }
        
        String insideBrackets = header.substring(openBracket + 1, closeBracket);
        
        if (insideBrackets.endsWith('\t')) {
            return '\t';
        }
        if (insideBrackets.endsWith('|')) {
            return '|';
        }
        
        return ',';
    }
    
    /**
     * Check if header is tabular format (has field list).
     */
    public Boolean isTabularHeader(String header) {
        Integer closeBracket = header.indexOf(']');
        if (closeBracket < 0) {
            return false;
        }
        
        String afterBracket = header.substring(closeBracket + 1);
        return afterBracket.trim().startsWith('{');
    }
    
    /**
     * Extract field names from tabular header.
     */
    public List<String> extractTabularFields(String header, String arrayDelimiter) {
        Integer openBrace = header.indexOf('{');
        Integer closeBrace = header.indexOf('}');
        
        if (openBrace < 0 || closeBrace < 0) {
            return new List<String>();
        }
        
        String fieldsStr = header.substring(openBrace + 1, closeBrace);
        List<String> fields = new List<String>();
        
        List<String> rawFields = fieldsStr.split(Pattern.quote(arrayDelimiter));
        for (String field : rawFields) {
            String trimmed = field.trim();
            if (trimmed.startsWith('"')) {
                trimmed = ToonStringValidator.removeQuotes(trimmed);
                trimmed = ToonStringEscaper.unescape(trimmed);
            }
            fields.add(trimmed);
        }
        
        return fields;
    }
    
    /**
     * Extract array length from header.
     */
    public Integer extractArrayLength(String header) {
        Integer openBracket = header.indexOf('[');
        Integer closeBracket = header.indexOf(']');
        
        if (openBracket < 0 || closeBracket < 0) {
            return 0;
        }
        
        String insideBrackets = header.substring(openBracket + 1, closeBracket);
        
        if (insideBrackets.startsWith('#')) {
            insideBrackets = insideBrackets.substring(1);
        }
        
        if (insideBrackets.endsWith('\t') || insideBrackets.endsWith('|')) {
            insideBrackets = insideBrackets.substring(0, insideBrackets.length() - 1);
        }
        
        try {
            return Integer.valueOf(insideBrackets.trim());
        } catch (Exception e) {
            return 0;
        }
    }
    
    /**
     * Get current line content trimmed to depth.
     */
    public String getCurrentContent(Integer depth) {
        if (currentLine >= lines.size()) {
            return '';
        }
        
        String line = lines[currentLine];
        Integer lineDepth = getDepth(line);
        
        if (lineDepth != depth) {
            return '';
        }
        
        Integer startPos = depth * indentSize;
        
        if (startPos >= line.length()) {
            return '';
        }
        
        return line.substring(startPos);
    }
    
    /**
     * Check if there are more lines to parse.
     */
    public Boolean hasMoreLines() {
        return currentLine < lines.size();
    }
    
    /**
     * Get current line number.
     */
    public Integer getCurrentLineNumber() {
        return currentLine;
    }
    
    /**
     * Advance to next line.
     */
    public void nextLine() {
        currentLine++;
    }
    
    /**
     * Get line at specific index.
     */
    public String getLine(Integer index) {
        if (index < 0 || index >= lines.size()) {
            return '';
        }
        return lines[index];
    }
    
    /**
     * Peek at next line without advancing.
     */
    public String peekNextLine() {
        if (currentLine + 1 >= lines.size()) {
            return '';
        }
        return lines[currentLine + 1];
    }
}
