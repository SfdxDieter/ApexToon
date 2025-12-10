/**
 * Main orchestrator for decoding TOON format to Apex objects.
 * 
 * Handles parsing of complete TOON documents into Map/List structures.
 */
public class ToonValueDecoder {
    
    /**
     * Decode TOON string to Apex object with default options.
     * @param toon The TOON format string to decode
     * @return Decoded Apex object (Map, List, or primitive)
     */
    public static Object decode(String toon) {
        return decode(toon, new DecodeOptions());
    }
    
    /**
     * Decode TOON string to Apex object with custom options.
     * @param toon The TOON format string to decode
     * @param options Custom decoding options
     * @return Decoded Apex object (Map, List, or primitive)
     */
    public static Object decode(String toon, DecodeOptions options) {
        if (String.isBlank(toon)) {
            return new Map<String, Object>();
        }
        
        String trimmed = toon.trim();
        
        if (trimmed == 'null') {
            return null;
        }
        
        ToonParser parser = new ToonParser(toon, options);
        Object result = parseValue(parser, 0);
        
        return result != null ? result : new Map<String, Object>();
    }
    
    /**
     * Parse a value at the current parser position.
     * @param parser The ToonParser instance
     * @param depth The current indentation depth
     * @return Parsed value (Map, List, or primitive)
     */
    private static Object parseValue(ToonParser parser, Integer depth) {
        if (!parser.hasMoreLines()) {
            return null;
        }
        
        String line = parser.getLine(parser.getCurrentLineNumber());
        Integer lineDepth = parser.getDepth(line);
        
        if (lineDepth > depth) {
            throw new ToonDecodingException('Unexpected indentation at line ' + parser.getCurrentLineNumber());
        }
        
        String content = parser.getCurrentContent(depth);
        
        // Check for list item array (starts with '-')
        if (content.startsWith('-')) {
            return parseListArray(parser, depth - 1);
        }
        
        if (parser.isArrayHeader(content)) {
            return parseArray(parser, content, depth);
        }
        
        if (parser.isKeyedArray(content)) {
            return parseKeyedStructure(parser, content, depth);
        }
        
        Integer colonIdx = parser.findUnquotedColon(content);
        if (colonIdx > 0) {
            return parseObject(parser, depth);
        }
        
        parser.nextLine();
        return ToonPrimitiveDecoder.parse(content);
    }
    
    /**
     * Parse an object (map) structure.
     * @param parser The ToonParser instance
     * @param depth The current indentation depth
     * @return Map representation of the object
     */
    private static Map<String, Object> parseObject(ToonParser parser, Integer depth) {
        Map<String, Object> result = new Map<String, Object>();
        
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth) {
                break;
            }
            
            if (lineDepth > depth) {
                parser.nextLine();
                continue;
            }
            
            String content = parser.getCurrentContent(depth);
            
            if (parser.isKeyedArray(content)) {
                parseKeyedArrayIntoMap(parser, content, depth, result);
            } else {
                parseKeyValuePair(parser, content, depth, result);
            }
        }
        
        return result;
    }
    
    /**
     * Parse a single key-value pair into the map.
     * @param parser The ToonParser instance
     * @param content The content string containing the key-value pair
     * @param depth The current indentation depth
     * @param result The map to populate with the parsed key-value pair
     */
    private static void parseKeyValuePair(ToonParser parser, String content, Integer depth, Map<String, Object> result) {
        Integer colonIdx = parser.findUnquotedColon(content);
        
        if (colonIdx <= 0) {
            parser.nextLine();
            return;
        }
        
        String key = content.substring(0, colonIdx).trim();
        String value = content.substring(colonIdx + 1).trim();
        
        if (key.startsWith('"')) {
            key = ToonStringValidator.removeQuotes(key);
            key = ToonStringEscaper.unescape(key);
        }
        
        if (String.isBlank(value)) {
            parser.nextLine();
            if (parser.hasMoreLines()) {
                String nextLine = parser.getLine(parser.getCurrentLineNumber());
                if (!String.isBlank(nextLine) && parser.getDepth(nextLine) > depth) {
                    Object nestedValue = parseNestedValue(parser, depth);
                    result.put(key, nestedValue);
                    return;
                }
            }
            result.put(key, '');
        } else {
            parser.nextLine();
            result.put(key, ToonPrimitiveDecoder.parse(value));
        }
    }
    
    /**
     * Parse a nested value (object or array).
     * @param parser The ToonParser instance
     * @param parentDepth The parent indentation depth
     * @return Parsed nested object (Map, List, or primitive)
     */
    private static Object parseNestedValue(ToonParser parser, Integer parentDepth) {
        if (!parser.hasMoreLines()) {
            return new Map<String, Object>();
        }
        
        String nextLine = parser.getLine(parser.getCurrentLineNumber());
        Integer nextDepth = parser.getDepth(nextLine);
        
        if (nextDepth <= parentDepth) {
            return new Map<String, Object>();
        }
        
        String content = parser.getCurrentContent(nextDepth);
        
        // Check for list format
        if (content.startsWith('-')) {
            return parseListArray(parser, parentDepth);
        }
        
        if (parser.isArrayHeader(content)) {
            return parseArray(parser, content, nextDepth);
        }
        
        if (parser.isKeyedArray(content)) {
            Map<String, Object> result = new Map<String, Object>();
            parseKeyedArrayIntoMap(parser, content, nextDepth, result);
            return result;
        }
        
        // Default to parsing as object
        return parseObject(parser, nextDepth);
    }
    
    /**
     * Parse an array structure.
     * @param parser The ToonParser instance
     * @param header The array header string
     * @param depth The current indentation depth
     * @return List of parsed array values
     */
    private static List<Object> parseArray(ToonParser parser, String header, Integer depth) {
        String arrayDelimiter = parser.extractDelimiterFromHeader(header);
        
        if (parser.isTabularHeader(header)) {
            return parseTabularArray(parser, header, depth, arrayDelimiter);
        }
        
        Integer colonIdx = header.indexOf(':');
        if (colonIdx < 0) {
            parser.nextLine();
            return new List<Object>();
        }
        
        String afterColon = header.substring(colonIdx + 1).trim();
        
        if (!String.isBlank(afterColon)) {
            parser.nextLine();
            return ToonPrimitiveDecoder.parseDelimitedValues(afterColon, arrayDelimiter);
        }
        
        parser.nextLine();
        
        if (!parser.hasMoreLines()) {
            return new List<Object>();
        }
        
        String nextLine = parser.getLine(parser.getCurrentLineNumber());
        Integer nextDepth = parser.getDepth(nextLine);
        
        if (nextDepth <= depth) {
            return new List<Object>();
        }
        
        String nextContent = parser.getCurrentContent(nextDepth);
        
        if (nextContent.startsWith('-')) {
            return parseListArray(parser, depth);
        }
        
        List<Object> values = ToonPrimitiveDecoder.parseDelimitedValues(nextContent, arrayDelimiter);
        parser.nextLine();
        return values;
    }
    
    /**
     * Parse tabular array format.
     * @param parser The ToonParser instance
     * @param header The array header string
     * @param depth The current indentation depth
     * @param arrayDelimiter The delimiter character for array values
     * @return List of parsed tabular rows as maps
     */
    private static List<Object> parseTabularArray(ToonParser parser, String header, Integer depth, String arrayDelimiter) {
        List<String> fields = parser.extractTabularFields(header, arrayDelimiter);
        List<Object> result = new List<Object>();
        
        parser.nextLine();
        
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth + 1) {
                break;
            }
            
            if (lineDepth == depth + 1) {
                String rowContent = parser.getCurrentContent(lineDepth);
                Map<String, Object> row = parseTabularRow(rowContent, fields, arrayDelimiter);
                result.add(row);
                parser.nextLine();
            } else {
                parser.nextLine();
            }
        }
        
        return result;
    }
    
    /**
     * Parse a single tabular row.
     * @param rowContent The row content string
     * @param fields The list of field names
     * @param delimiter The delimiter character
     * @return Map representing the parsed row with field names as keys
     */
    private static Map<String, Object> parseTabularRow(String rowContent, List<String> fields, String delimiter) {
        Map<String, Object> row = new Map<String, Object>();
        List<Object> values = ToonPrimitiveDecoder.parseDelimitedValues(rowContent, delimiter);
        
        for (Integer i = 0; i < fields.size() && i < values.size(); i++) {
            row.put(fields[i], values[i]);
        }
        
        return row;
    }
    
    /**
     * Parse list item array format.
     * @param parser The ToonParser instance
     * @param depth The current indentation depth
     * @return List of parsed list items
     */
    private static List<Object> parseListArray(ToonParser parser, Integer depth) {
        List<Object> result = new List<Object>();
        
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth + 1) {
                break;
            }
            
            if (lineDepth == depth + 1) {
                String content = parser.getCurrentContent(lineDepth);
                
                if (content.startsWith('-')) {
                    Object item = parseListItem(parser, content, depth);
                    result.add(item);
                } else {
                    break;
                }
            } else {
                parser.nextLine();
            }
        }
        
        return result;
    }
    
    /**
     * Parse a single list item.
     * 
     * Per TOON v3.0 (Section 10):
     * - If item starts with keyed tabular array: rows at depth +2, other fields at depth +1
     * - For all other cases: first field on hyphen line, other fields at depth +1
     * @param parser The ToonParser instance
     * @param content The content string of the list item
     * @param depth The current indentation depth
     * @return Parsed list item (Map, List, or primitive)
     */
    private static Object parseListItem(ToonParser parser, String content, Integer depth) {
        // Extract content after hyphen: '- value' -> 'value', or bare '-' -> ''
        String itemContent = '';
        if (content.length() > 1 && content.substring(1, 2) == ' ') {
            // Format: '- value'
            itemContent = content.substring(2).trim();
        } else if (content.length() > 1) {
            // Format: '-value' (no space)
            itemContent = content.substring(1).trim();
        }
        // If content is bare '-', itemContent remains empty string

        parser.nextLine();
        
        if (String.isBlank(itemContent)) {
            return new Map<String, Object>();
        }
        
        // Handle bare array header (e.g., "- [2]: a,b")
        if (parser.isArrayHeader(itemContent)) {
            return parseArray(parser, itemContent, depth + 1);
        }
        
        // TOON v3.0: Handle keyed tabular array as first field (e.g., "- users[2]{id,name}:")
        if (parser.isKeyedArray(itemContent) && parser.isTabularHeader(itemContent)) {
            Map<String, Object> itemObj = new Map<String, Object>();
            parseListItemTabularField(parser, itemContent, depth, itemObj);
            parseListItemFieldsAtDepthPlusOne(parser, itemObj, depth);
            return itemObj;
        }
        
        Integer colonIdx = parser.findUnquotedColon(itemContent);
        
        if (colonIdx <= 0) {
            return ToonPrimitiveDecoder.parse(itemContent);
        }
        
        Map<String, Object> itemObj = new Map<String, Object>();
        String key = itemContent.substring(0, colonIdx).trim();
        String value = itemContent.substring(colonIdx + 1).trim();
        
        if (key.startsWith('"')) {
            key = ToonStringValidator.removeQuotes(key);
            key = ToonStringEscaper.unescape(key);
        }
        
        // Check if key contains array brackets (keyed array that's not tabular)
        if (key.contains('[')) {
            Integer bracketIdx = key.indexOf('[');
            String arrayKey = key.substring(0, bracketIdx).trim();
            if (arrayKey.startsWith('"')) {
                arrayKey = ToonStringValidator.removeQuotes(arrayKey);
                arrayKey = ToonStringEscaper.unescape(arrayKey);
            }
            String arrayHeader = key.substring(bracketIdx) + ':' + (String.isBlank(value) ? '' : ' ' + value);
            List<Object> arrayValue = parseArray(parser, arrayHeader, depth + 1);
            itemObj.put(arrayKey, arrayValue);
            parseListItemFields(parser, itemObj, depth);
            return itemObj;
        }
        
        if (String.isBlank(value)) {
            Object nestedValue = parseNestedValue(parser, depth + 1);
            itemObj.put(key, nestedValue);
        } else {
            itemObj.put(key, ToonPrimitiveDecoder.parse(value));
        }
        
        parseListItemFields(parser, itemObj, depth);
        
        return itemObj;
    }
    
    /**
     * Parse a tabular array field in a list item (v3.0 format).
     * Reads header from hyphen line and rows at depth +2 relative to hyphen.
     * Note: depth parameter is the parent array depth, hyphen is at depth+1.
     * @param parser The ToonParser instance
     * @param content The content string containing the tabular array header
     * @param depth The parent array depth
     * @param itemObj The map to populate with the parsed tabular array
     */
    private static void parseListItemTabularField(ToonParser parser, String content, Integer depth, Map<String, Object> itemObj) {
        Integer bracketIdx = content.indexOf('[');
        String key = content.substring(0, bracketIdx).trim();
        
        if (key.startsWith('"')) {
            key = ToonStringValidator.removeQuotes(key);
            key = ToonStringEscaper.unescape(key);
        }
        
        String arrayHeader = content.substring(bracketIdx);
        String arrayDelimiter = parser.extractDelimiterFromHeader(arrayHeader);
        List<String> fields = parser.extractTabularFields(arrayHeader, arrayDelimiter);
        
        List<Object> result = new List<Object>();
        
        // Hyphen line is at depth+1, so rows are at (depth+1)+2 = depth+3
        Integer rowDepth = depth + 3;
        
        // Read tabular rows at depth +2 relative to hyphen line
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            // Rows must be at rowDepth (depth+3)
            if (lineDepth != rowDepth) {
                break;
            }
            
            String rowContent = parser.getCurrentContent(lineDepth);
            
            // If we hit a key-value line, stop reading rows
            Integer colonIdx = parser.findUnquotedColon(rowContent);
            if (colonIdx > 0) {
                // Check if colon appears before delimiter - means it's a key-value line
                Integer delimIdx = findUnquotedDelimiter(rowContent, arrayDelimiter);
                if (delimIdx < 0 || colonIdx < delimIdx) {
                    break;
                }
            }
            
            Map<String, Object> row = parseTabularRow(rowContent, fields, arrayDelimiter);
            result.add(row);
            parser.nextLine();
        }
        
        itemObj.put(key, result);
    }
    
    /**
     * Find index of first unquoted delimiter in content.
     * @param content The content string to search
     * @param delimiter The delimiter character to find
     * @return Index of first unquoted delimiter, or -1 if not found
     */
    private static Integer findUnquotedDelimiter(String content, String delimiter) {
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
            } else if (chr == delimiter && !inQuotes) {
                return i;
            }
        }
        
        return -1;
    }
    
    /**
     * Parse additional fields in a list item object at depth +1 relative to hyphen.
     * Used after tabular array field in v3.0 format.
     * Note: depth parameter is parent array depth, hyphen is at depth+1, sibling fields at depth+2.
     * @param parser The ToonParser instance
     * @param itemObj The map to populate with parsed fields
     * @param depth The parent array depth
     */
    private static void parseListItemFieldsAtDepthPlusOne(ToonParser parser, Map<String, Object> itemObj, Integer depth) {
        // Hyphen is at depth+1, sibling fields are at (depth+1)+1 = depth+2
        Integer siblingDepth = depth + 2;
        
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            // Fields are at siblingDepth (depth+2)
            if (lineDepth != siblingDepth) {
                break;
            }
            
            String content = parser.getCurrentContent(lineDepth);
            
            // Stop if we hit another list item (shouldn't happen at this depth, but be safe)
            if (content.startsWith('-')) {
                break;
            }
            
            if (parser.isKeyedArray(content)) {
                parseKeyedArrayIntoMap(parser, content, lineDepth, itemObj);
            } else {
                parseKeyValuePair(parser, content, lineDepth, itemObj);
            }
        }
    }
    
    /**
     * Parse additional fields in a list item object.
     * @param parser The ToonParser instance
     * @param itemObj The map to populate with parsed fields
     * @param depth The current indentation depth
     */
    private static void parseListItemFields(ToonParser parser, Map<String, Object> itemObj, Integer depth) {
        while (parser.hasMoreLines()) {
            String line = parser.getLine(parser.getCurrentLineNumber());
            
            if (String.isBlank(line)) {
                parser.nextLine();
                continue;
            }
            
            Integer lineDepth = parser.getDepth(line);
            
            if (lineDepth < depth + 2) {
                break;
            }
            
            if (lineDepth == depth + 2) {
                String content = parser.getCurrentContent(lineDepth);
                
                if (parser.isKeyedArray(content)) {
                    parseKeyedArrayIntoMap(parser, content, lineDepth, itemObj);
                } else {
                    parseKeyValuePair(parser, content, lineDepth, itemObj);
                }
            } else {
                parser.nextLine();
            }
        }
    }
    
    /**
     * Parse a keyed array structure.
     * @param parser The ToonParser instance
     * @param content The content string containing the keyed array
     * @param depth The current indentation depth
     * @return Parsed keyed structure as a Map
     */
    private static Object parseKeyedStructure(ToonParser parser, String content, Integer depth) {
        Map<String, Object> result = new Map<String, Object>();
        parseKeyedArrayIntoMap(parser, content, depth, result);
        return result;
    }
    
    /**
     * Parse keyed array into existing map.
     * @param parser The ToonParser instance
     * @param content The content string containing the keyed array
     * @param depth The current indentation depth
     * @param result The map to populate with the parsed keyed array
     */
    private static void parseKeyedArrayIntoMap(ToonParser parser, String content, Integer depth, Map<String, Object> result) {
        Integer bracketIdx = content.indexOf('[');
        String key = content.substring(0, bracketIdx).trim();
        
        if (key.startsWith('"')) {
            key = ToonStringValidator.removeQuotes(key);
            key = ToonStringEscaper.unescape(key);
        }
        
        String arrayHeader = content.substring(bracketIdx);
        List<Object> arrayValue = parseArray(parser, arrayHeader, depth);
        result.put(key, arrayValue);
    }
}
