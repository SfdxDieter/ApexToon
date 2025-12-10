/**
 * Encodes arrays/lists to TOON format.
 * 
 * Handles encoding of List<Object> structures with support for:
 * - Inline arrays (primitives): tags[3]: a,b,c
 * - Tabular arrays (uniform objects): items[2]{id,name}: ...
 * - List item arrays (mixed content): [2]: - item1 - item2
 */
public class ToonArrayEncoder {
    
    /**
     * Encode an array to TOON format.
     * 
     * Determines the best format based on array contents:
     * - All primitives -> inline format
     * - All maps with uniform keys -> tabular format
     * - Mixed or complex -> list item format
     * 
     * @param key Optional key (null for standalone array)
     * @param items The list to encode
     * @param writer The line writer to write output to
     * @param depth Current indentation depth
     * @param options Encoding options
     */
    public static void encodeArray(String key, List<Object> items, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        if (items == null) {
            String encodedKey = key != null ? ToonPrimitiveEncoder.encodeKey(key) : '';
            writer.push(depth, encodedKey + (encodedKey != '' ? ': ' : '') + 'null');
            return;
        }
        
        if (items.isEmpty()) {
            String header = ToonHeaderFormatter.formatInlineHeader(key, 0, options);
            writer.push(depth, header);
            return;
        }
        
        if (ToonTypeHelper.areAllPrimitives(items)) {
            encodeInlineArray(key, items, writer, depth, options);
        } else if (ToonTypeHelper.areAllMaps(items) && ToonTypeHelper.haveUniformKeys(items) && ToonTypeHelper.allMapValuesArePrimitives(items) && !((Map<String, Object>)items[0]).isEmpty()) {
            encodeTabularArray(key, items, writer, depth, options);
        } else {
            encodeListItemArray(key, items, writer, depth, options);
        }
    }
    
    /**
     * Encode array of primitives in inline format.
     * Format: tags[3]: a,b,c
     *
     * @param key Optional key for the array
     * @param items The list of primitive items to encode
     * @param writer The line writer to write output to
     * @param depth Current indentation depth
     * @param options Encoding options
     */
    private static void encodeInlineArray(String key, List<Object> items, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        String header = ToonHeaderFormatter.formatInlineHeader(key, items.size(), options);
        
        List<String> encodedValues = new List<String>();
        String delimiter = options.getDelimiterString();
        
        for (Object item : items) {
            encodedValues.add(ToonPrimitiveEncoder.encodePrimitive(item, delimiter));
        }
        
        String valuesLine = String.join(encodedValues, delimiter);
        writer.push(depth, header + ' ' + valuesLine);
    }
    
    /**
     * Encode array of uniform objects in tabular format.
     * Format:
     *   items[2]{id,name}:
     *     1,Alice
     *     2,Bob
     *
     * @param key Optional key for the array
     * @param items The list of uniform object items to encode
     * @param writer The line writer to write output to
     * @param depth Current indentation depth
     * @param options Encoding options
     */
    private static void encodeTabularArray(String key, List<Object> items, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        List<String> fields = ToonTypeHelper.getUniformKeys(items);
        String header = ToonHeaderFormatter.formatTabularHeader(key, items.size(), fields, options);
        writer.push(depth, header);
        
        String delimiter = options.getDelimiterString();
        
        for (Object item : items) {
            Map<String, Object> obj = (Map<String, Object>) item;
            List<String> rowValues = new List<String>();
            
            for (String field : fields) {
                Object value = obj.get(field);
                rowValues.add(ToonPrimitiveEncoder.encodePrimitive(value, delimiter));
            }
            
            writer.push(depth + 1, String.join(rowValues, delimiter));
        }
    }
    
    /**
     * Encode array with mixed or complex items using list format.
     * Format:
     *   items[2]:
     *   - item1
     *     nested: value
     *   - item2
     *     nested: value
     *
     * @param key Optional key for the array
     * @param items The list of mixed or complex items to encode
     * @param writer The line writer to write output to
     * @param depth Current indentation depth
     * @param options Encoding options
     */
    private static void encodeListItemArray(String key, List<Object> items, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        String header = ToonHeaderFormatter.formatInlineHeader(key, items.size(), options);
        writer.push(depth, header);
        
        for (Object item : items) {
            if (ToonTypeHelper.isPrimitive(item)) {
                String encodedValue = ToonPrimitiveEncoder.encodePrimitive(item, options.getDelimiterString());
                writer.push(depth + 1, '- ' + encodedValue);
            } else if (ToonTypeHelper.isMap(item)) {
                Map<String, Object> obj = (Map<String, Object>) item;
                encodeListItemObject(obj, writer, depth + 1, options);
            } else if (ToonTypeHelper.isList(item)) {
                writer.push(depth + 1, '-');
                encodeArray(null, (List<Object>) item, writer, depth + 2, options);
            } else {
                throw new ToonEncodingException('Unsupported item type in array: ' + ToonTypeHelper.getTypeName(item));
            }
        }
    }
    
    /**
     * Encode an object as a list item.
     * 
     * Per TOON v3.0 (Section 10):
     * - If first field is a tabular array: emit header on hyphen line, rows at depth +2, other fields at depth +1
     * - For all other cases: first field on same line as dash, rest indented at depth +1
     *
     * @param obj The map object to encode as a list item
     * @param writer The line writer to write output to
     * @param depth Current indentation depth
     * @param options Encoding options
     */
    private static void encodeListItemObject(Map<String, Object> obj, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        List<String> keys = new List<String>(obj.keySet());
        
        if (keys.isEmpty()) {
            writer.push(depth, '-');
            return;
        }
        
        String firstKey = keys[0];
        Object firstValue = obj.get(firstKey);
        String encodedKey = ToonPrimitiveEncoder.encodeKey(firstKey);
        
        // TOON v3.0: Handle tabular array as first field
        if (ToonTypeHelper.isTabularArray(firstValue)) {
            List<Object> tabularItems = (List<Object>) firstValue;
            List<String> fields = ToonTypeHelper.getUniformKeys(tabularItems);
            String header = ToonHeaderFormatter.formatTabularHeader(encodedKey, tabularItems.size(), fields, options);
            
            // Emit header on hyphen line: - key[N]{fields}:
            writer.push(depth, '- ' + header);
            
            // Emit tabular rows at depth +2
            String delimiter = options.getDelimiterString();
            for (Object item : tabularItems) {
                Map<String, Object> rowObj = (Map<String, Object>) item;
                List<String> rowValues = new List<String>();
                
                for (String field : fields) {
                    Object value = rowObj.get(field);
                    rowValues.add(ToonPrimitiveEncoder.encodePrimitive(value, delimiter));
                }
                
                writer.push(depth + 2, String.join(rowValues, delimiter));
            }
            
            // Emit remaining fields at depth +1
            for (Integer i = 1; i < keys.size(); i++) {
                String key = keys[i];
                Object value = obj.get(key);
                ToonObjectEncoder.encodeKeyValuePair(key, value, writer, depth + 1, options);
            }
        } else if (ToonTypeHelper.isPrimitive(firstValue)) {
            String encodedValue = ToonPrimitiveEncoder.encodePrimitive(firstValue, options.getDelimiterString());
            writer.push(depth, '- ' + encodedKey + ': ' + encodedValue);
            
            for (Integer i = 1; i < keys.size(); i++) {
                String key = keys[i];
                Object value = obj.get(key);
                ToonObjectEncoder.encodeKeyValuePair(key, value, writer, depth + 1, options);
            }
        } else {
            writer.push(depth, '- ' + encodedKey + ':');
            if (ToonTypeHelper.isMap(firstValue)) {
                ToonObjectEncoder.encodeObject((Map<String, Object>) firstValue, writer, depth + 1, options);
            } else if (ToonTypeHelper.isList(firstValue)) {
                encodeArray(null, (List<Object>) firstValue, writer, depth + 1, options);
            }
            
            for (Integer i = 1; i < keys.size(); i++) {
                String key = keys[i];
                Object value = obj.get(key);
                ToonObjectEncoder.encodeKeyValuePair(key, value, writer, depth + 1, options);
            }
        }
    }
}
