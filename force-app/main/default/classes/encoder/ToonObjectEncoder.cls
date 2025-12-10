/**
 * Encodes Map objects to TOON format.
 * 
 * Handles encoding of Map<String, Object> structures with nested objects,
 * arrays, and primitive values.
 */
public class ToonObjectEncoder {
    
    /**
     * Encode a Map to TOON format.
     * 
     * @param obj The Map to encode
     * @param writer The LineWriter to accumulate output
     * @param depth Current indentation depth
     * @param options Encoding options
     */
    public static void encodeObject(Map<String, Object> obj, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        if (obj == null || obj.isEmpty()) {
            return;
        }
        
        for (String key : obj.keySet()) {
            Object value = obj.get(key);
            encodeKeyValuePair(key, value, writer, depth, options);
        }
    }
    
    /**
     * Encode a single key-value pair.
     * 
     * Determines the type of value and routes to appropriate encoder:
     * - Primitive: inline as "key: value"
     * - Map: nested object with recursive encoding
     * - List: delegates to ToonArrayEncoder
     * 
     * @param key The object key
     * @param value The value to encode
     * @param writer The LineWriter
     * @param depth Current depth
     * @param options Encoding options
     */
    public static void encodeKeyValuePair(String key, Object value, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        String encodedKey = ToonPrimitiveEncoder.encodeKey(key);
        
        if (ToonTypeHelper.isPrimitive(value)) {
            encodePrimitiveField(encodedKey, value, writer, depth, options);
        } else if (ToonTypeHelper.isList(value)) {
            List<Object> listValue = (List<Object>) value;
            ToonArrayEncoder.encodeArray(encodedKey, listValue, writer, depth, options);
        } else if (ToonTypeHelper.isMap(value)) {
            encodeNestedObject(encodedKey, (Map<String, Object>) value, writer, depth, options);
        } else if (ToonTypeHelper.isSObject(value)) {
            encodeSObjectField(encodedKey, (SObject) value, writer, depth, options);
        } else {
            throw new ToonEncodingException('Unsupported value type for key "' + key + '": ' + ToonTypeHelper.getTypeName(value));
        }
    }
    
    /**
     * Encode a primitive field inline.
     * Format: "key: value"
     */
    private static void encodePrimitiveField(String encodedKey, Object value, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        String encodedValue = ToonPrimitiveEncoder.encodePrimitive(value, options.getDelimiterString());
        writer.push(depth, encodedKey + ': ' + encodedValue);
    }
    
    /**
     * Encode a nested object.
     * Format:
     *   key:
     *     nestedKey1: value1
     *     nestedKey2: value2
     */
    private static void encodeNestedObject(String encodedKey, Map<String, Object> nestedObj, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        writer.push(depth, encodedKey + ':');
        encodeObject(nestedObj, writer, depth + 1, options);
    }
    
    /**
     * Encode an SObject field by converting it to a Map.
     *
     * @param encodedKey The encoded key string
     * @param obj The SObject to encode
     * @param writer The line writer to write output to
     * @param depth Current indentation depth
     * @param options Encoding options
     */
    private static void encodeSObjectField(String encodedKey, SObject obj, ToonLineWriter writer, Integer depth, EncodeOptions options) {
        String jsonStr = JSON.serialize(obj);
        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        
        objMap.remove('attributes');
        
        encodeNestedObject(encodedKey, objMap, writer, depth, options);
    }
}
