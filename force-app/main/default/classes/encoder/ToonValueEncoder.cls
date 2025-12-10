/**
 * Main encoder orchestrator for TOON format.
 * 
 * Routes values to appropriate specialized encoders based on type.
 */
public class ToonValueEncoder {
    
    /**
     * Encode any value to TOON format.
     * 
     * Entry point for encoding. Determines value type and routes to
     * appropriate encoder.
     * 
     * @param value The value to encode
     * @param options Encoding options
     * @return TOON-formatted string
     */
    public static String encodeValue(Object value, EncodeOptions options) {
        if (ToonTypeHelper.isPrimitive(value)) {
            return ToonPrimitiveEncoder.encodePrimitive(value, options.getDelimiterString());
        }
        
        ToonLineWriter writer = new ToonLineWriter(options.indent);
        
        if (ToonTypeHelper.isList(value)) {
            List<Object> listValue = (List<Object>) value;
            ToonArrayEncoder.encodeArray(null, listValue, writer, 0, options);
        } else if (ToonTypeHelper.isMap(value)) {
            Map<String, Object> mapValue = (Map<String, Object>) value;
            ToonObjectEncoder.encodeObject(mapValue, writer, 0, options);
        } else if (ToonTypeHelper.isSObject(value)) {
            encodeSObject((SObject) value, writer, options);
        } else {
            throw new ToonEncodingException('Unsupported type: ' + ToonTypeHelper.getTypeName(value));
        }
        
        return writer.toString();
    }
    
    /**
     * Encode an SObject by converting it to a Map first.
     *
     * @param obj The SObject to encode
     * @param writer The line writer to write output to
     * @param options Encoding options
     */
    private static void encodeSObject(SObject obj, ToonLineWriter writer, EncodeOptions options) {
        String jsonStr = JSON.serialize(obj);
        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        
        objMap.remove('attributes');
        
        ToonObjectEncoder.encodeObject(objMap, writer, 0, options);
    }
}
