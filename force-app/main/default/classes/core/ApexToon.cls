/**
 * Main API class for ApexToon - Token-Oriented Object Notation for Salesforce.
 *
 * ApexToon converts between Apex objects/JSON and TOON format, which is optimized
 * for LLM token efficiency while maintaining human readability.
 *
 * Example usage:
 *   Map<String, Object> data = new Map<String, Object>{ 'id' => 123, 'name' => 'Ada' };
 *   String toon = ApexToon.encode(data);
 *   Object decoded = ApexToon.decode(toon);
 */
global class ApexToon {

    /**
     * Encode an Apex object to TOON format using default options.
     *
     * @param value The Apex object to encode
     * @return TOON-formatted string
     */
    global static String encode(Object value) {
        return encode(value, new EncodeOptions());
    }

    /**
     * Encode an Apex object to TOON format with custom options.
     *
     * @param value The Apex object to encode
     * @param options Custom encoding options
     * @return TOON-formatted string
     */
    global static String encode(Object value, EncodeOptions options) {
        if (options == null) {
            options = new EncodeOptions();
        }
        return ToonValueEncoder.encodeValue(value, options);
    }

    /**
     * Encode a JSON string to TOON format using default options.
     *
     * @param jsonString The JSON string to encode
     * @return TOON-formatted string
     */
    global static String encodeJson(String jsonString) {
        return encodeJson(jsonString, new EncodeOptions());
    }

    /**
     * Encode a JSON string to TOON format with custom options.
     *
     * @param jsonString The JSON string to encode
     * @param options Custom encoding options
     * @return TOON-formatted string
     */
    global static String encodeJson(String jsonString, EncodeOptions options) {
        Object value = JSON.deserializeUntyped(jsonString);
        return encode(value, options);
    }

    /**
     * Decode a TOON string to an Apex object using default options.
     *
     * @param toon The TOON-formatted string to decode
     * @return Decoded Apex object
     */
    global static Object decode(String toon) {
        return decode(toon, new DecodeOptions());
    }

    /**
     * Decode a TOON string to an Apex object with custom options.
     *
     * @param toon The TOON-formatted string to decode
     * @param options Custom decoding options
     * @return Decoded Apex object
     */
    global static Object decode(String toon, DecodeOptions options) {
        if (options == null) {
            options = new DecodeOptions();
        }
        return ToonValueDecoder.decode(toon, options);
    }

    /**
     * Decode a TOON string and return as JSON string.
     *
     * @param toon The TOON-formatted string to decode
     * @return JSON string representation
     */
    global static String decodeToJson(String toon) {
        return decodeToJson(toon, new DecodeOptions());
    }

    /**
     * Decode a TOON string and return as JSON string with custom options.
     *
     * @param toon The TOON-formatted string to decode
     * @param options Custom decoding options
     * @return JSON string representation
     */
    global static String decodeToJson(String toon, DecodeOptions options) {
        Object value = decode(toon, options);
        return JSON.serialize(value);
    }

    // ========================================
    // SObject Encoding Methods
    // ========================================

    /**
     * Encode a list of SObjects with explicit field selection using SObjectField.
     *
     * @param records List of SObjects to encode (must be same type)
     * @param fields List of SObjectFields to include in output
     * @return TOON-formatted string
     *
     * @example
     * List<Account> accounts = [SELECT Name, Industry FROM Account LIMIT 10];
     * String toon = ApexToon.encodeSObjects(accounts, new List<Schema.SObjectField>{
     *     Account.Name,
     *     Account.Industry
     * });
     */
    global static String encodeSObjects(List<SObject> records, List<Schema.SObjectField> fields) {
        return ToonSObjectEncoder.encodeSObjects(records, fields, new EncodeOptions());
    }

    /**
     * Encode SObjects with explicit field selection and custom options.
     *
     * @param records List of SObjects to encode (must be same type)
     * @param fields List of SObjectFields to include in output
     * @param options Custom encoding options
     * @return TOON-formatted string
     */
    global static String encodeSObjects(List<SObject> records, List<Schema.SObjectField> fields, EncodeOptions options) {
        return ToonSObjectEncoder.encodeSObjects(records, fields, options);
    }

    /**
     * Encode SObjects using field names (supports relationships via dot notation).
     *
     * @param records List of SObjects to encode (must be same type)
     * @param fieldNames List of field API names (e.g., 'Name', 'Account.Name')
     * @return TOON-formatted string
     *
     * @example
     * List<Contact> contacts = [
     *     SELECT FirstName, LastName, Account.Name
     *     FROM Contact LIMIT 10
     * ];
     * String toon = ApexToon.encodeSObjects(contacts, new List<String>{
     *     'FirstName',
     *     'LastName',
     *     'Account.Name'
     * });
     */
    global static String encodeSObjects(List<SObject> records, List<String> fieldNames) {
        return ToonSObjectEncoder.encodeSObjects(records, fieldNames, new EncodeOptions());
    }

    /**
     * Encode SObjects using field names with custom options.
     *
     * @param records List of SObjects to encode (must be same type)
     * @param fieldNames List of field API names (e.g., 'Name', 'Account.Name')
     * @param options Custom encoding options
     * @return TOON-formatted string
     */
    global static String encodeSObjects(List<SObject> records, List<String> fieldNames, EncodeOptions options) {
        return ToonSObjectEncoder.encodeSObjects(records, fieldNames, options);
    }

    /**
     * Encode a single SObject with explicit fields.
     *
     * @param record SObject to encode
     * @param fields List of fields to include
     * @return TOON-formatted string (single object)
     */
    global static String encodeSObject(SObject record, List<Schema.SObjectField> fields) {
        return encodeSObjects(new List<SObject>{ record }, fields);
    }

    /**
     * Encode a single SObject using field names.
     *
     * @param record SObject to encode
     * @param fieldNames List of field API names to include
     * @return TOON-formatted string (single object)
     */
    global static String encodeSObject(SObject record, List<String> fieldNames) {
        return encodeSObjects(new List<SObject>{ record }, fieldNames);
    }

    /**
     * Encode a single SObject with explicit fields and custom options.
     *
     * @param record SObject to encode
     * @param fields List of SObjectFields to include
     * @param options Custom encoding options
     * @return TOON-formatted string (single object)
     */
    global static String encodeSObject(SObject record, List<Schema.SObjectField> fields, EncodeOptions options) {
        return encodeSObjects(new List<SObject>{ record }, fields, options);
    }

    /**
     * Encode a single SObject using field names with custom options.
     *
     * @param record SObject to encode
     * @param fieldNames List of field API names to include
     * @param options Custom encoding options
     * @return TOON-formatted string (single object)
     */
    global static String encodeSObject(SObject record, List<String> fieldNames, EncodeOptions options) {
        return encodeSObjects(new List<SObject>{ record }, fieldNames, options);
    }
}
