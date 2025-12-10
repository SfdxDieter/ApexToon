/**
 * Integration tests for ApexToon decoding.
 * Tests the complete decoding pipeline from TOON strings to Apex objects.
 */
@IsTest
private class ApexToonDecodingTest {
    
    @IsTest
    private static void testDecodePrimitiveNull() {
        // Given
        String toon = 'null';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(null, result, 'Should decode null');
    }
    
    @IsTest
    private static void testDecodePrimitiveBoolean() {
        // Given
        String toon = 'true';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Should decode boolean');
    }
    
    @IsTest
    private static void testDecodePrimitiveNumber() {
        // Given
        String toon = '42';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(42L, result, 'Should decode number');
    }
    
    @IsTest
    private static void testDecodePrimitiveString() {
        // Given
        String toon = 'hello';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual('hello', result, 'Should decode string');
    }
    
    @IsTest
    private static void testDecodeSimpleObject() {
        // Given
        String toon = 'id: 123\nname: Ada\nactive: true';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.isTrue(result instanceof Map<String, Object>, 'Should return Map');
        Map<String, Object> obj = (Map<String, Object>) result;
        Assert.areEqual(123L, obj.get('id'), 'Should have id field');
        Assert.areEqual('Ada', obj.get('name'), 'Should have name field');
        Assert.areEqual(true, obj.get('active'), 'Should have active field');
    }
    
    @IsTest
    private static void testDecodeNestedObject() {
        // Given
        String toon = 'id: 1\nuser:\n  name: Alice\n  age: 30';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        Assert.areEqual(1L, obj.get('id'), 'Should have id');
        Assert.isTrue(obj.containsKey('user'), 'Should have user key');
        
        Map<String, Object> user = (Map<String, Object>) obj.get('user');
        Assert.areEqual('Alice', user.get('name'), 'Should have nested name');
        Assert.areEqual(30L, user.get('age'), 'Should have nested age');
    }
    
    @IsTest
    private static void testDecodePrimitiveArray() {
        // Given
        String toon = '[3]: admin,ops,dev';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.isTrue(result instanceof List<Object>, 'Should return List');
        List<Object> arrayResult = (List<Object>) result;
        Assert.areEqual(3, arrayResult.size(), 'Should have 3 items');
        Assert.areEqual('admin', arrayResult[0], 'First item should be admin');
        Assert.areEqual('ops', arrayResult[1], 'Second item should be ops');
        Assert.areEqual('dev', arrayResult[2], 'Third item should be dev');
    }
    
    @IsTest
    private static void testDecodeTabularArray() {
        // Given
        String toon = '[2]{id,name}:\n  1,Alice\n  2,Bob';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> arrayResult = (List<Object>) result;
        Assert.areEqual(2, arrayResult.size(), 'Should have 2 items');
        
        Map<String, Object> first = (Map<String, Object>) arrayResult[0];
        Assert.areEqual(1L, first.get('id'), 'First row id');
        Assert.areEqual('Alice', first.get('name'), 'First row name');
        
        Map<String, Object> second = (Map<String, Object>) arrayResult[1];
        Assert.areEqual(2L, second.get('id'), 'Second row id');
        Assert.areEqual('Bob', second.get('name'), 'Second row name');
    }
    
    @IsTest
    private static void testDecodeObjectWithArray() {
        // Given
        String toon = 'user: Alice\ntags[2]: admin,dev';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        Assert.areEqual('Alice', obj.get('user'), 'Should have user field');
        
        List<Object> tags = (List<Object>) obj.get('tags');
        Assert.areEqual(2, tags.size(), 'Should have 2 tags');
        Assert.areEqual('admin', tags[0], 'First tag');
        Assert.areEqual('dev', tags[1], 'Second tag');
    }
    
    @IsTest
    private static void testDecodeEmptyArray() {
        // Given
        String toon = '[0]:';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> arrayResult = (List<Object>) result;
        Assert.areEqual(0, arrayResult.size(), 'Should be empty arrayResult');
    }
    
    @IsTest
    private static void testDecodeEmptyObject() {
        // Given
        String toon = '';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        Assert.areEqual(0, obj.size(), 'Should be empty object');
    }
    
    @IsTest
    private static void testDecodeMixedArray() {
        // Given
        String toon = '- string\n- 123\n- key: value';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> arrayResult = (List<Object>) result;
        Assert.areEqual(3, arrayResult.size(), 'Should have 3 items');
        Assert.areEqual('string', arrayResult[0], 'First item string');
        Assert.areEqual(123L, arrayResult[1], 'Second item number');
        
        Map<String, Object> third = (Map<String, Object>) arrayResult[2];
        Assert.areEqual('value', third.get('key'), 'Third item object');
    }
    
    @IsTest
    private static void testDecodeComplexNested() {
        // Given
        String toon = 'project: TOON\nmetadata:\n  version: 1.0\n  authors[2]: Alice,Bob\nitems[2]{id,status}:\n  1,active\n  2,pending';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        Assert.areEqual('TOON', obj.get('project'), 'Should have project');
        
        Map<String, Object> metadata = (Map<String, Object>) obj.get('metadata');
        Assert.areEqual(1.0, metadata.get('version'), 'Should have version');
        
        List<Object> authors = (List<Object>) metadata.get('authors');
        Assert.areEqual(2, authors.size(), 'Should have 2 authors');
        
        List<Object> items = (List<Object>) obj.get('items');
        Assert.areEqual(2, items.size(), 'Should have 2 items');
        
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        Assert.areEqual(1L, firstItem.get('id'), 'First item id');
        Assert.areEqual('active', firstItem.get('status'), 'First item status');
    }
    
    @IsTest
    private static void testDecodeWithTabDelimiter() {
        // Given
        String toon = '[3\t]: 1\t2\t3';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> arrayResult = (List<Object>) result;
        Assert.areEqual(3, arrayResult.size(), 'Should parse tab-delimited');
        Assert.areEqual(1L, arrayResult[0], 'First value');
        Assert.areEqual(2L, arrayResult[1], 'Second value');
        Assert.areEqual(3L, arrayResult[2], 'Third value');
    }
    
    @IsTest
    private static void testDecodeWithPipeDelimiter() {
        // Given
        String toon = '[2|]: a|b';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> arrayResult = (List<Object>) result;
        Assert.areEqual(2, arrayResult.size(), 'Should parse pipe-delimited');
        Assert.areEqual('a', arrayResult[0], 'First value');
        Assert.areEqual('b', arrayResult[1], 'Second value');
    }
    
    @IsTest
    private static void testDecodeQuotedKeys() {
        // Given
        String toon = '"my-key": value\n"another key": 123';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        Assert.areEqual('value', obj.get('my-key'), 'Should decode quoted key');
        Assert.areEqual(123L, obj.get('another key'), 'Should decode key with space');
    }
    
    @IsTest
    private static void testDecodeQuotedValues() {
        // Given
        String toon = 'text: "hello, world"\nescaped: "line1\\nline2"';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        Assert.areEqual('hello, world', obj.get('text'), 'Should decode quoted value');
        Assert.areEqual('line1\nline2', obj.get('escaped'), 'Should unescape sequences');
    }
    
    @IsTest
    private static void testDecodeToJson() {
        // Given
        String toon = 'id: 123\nname: Ada';

        // When
        Test.startTest();
        String jsonResult = ApexToon.decodeToJson(toon);
        Test.stopTest();

        // Then
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(jsonResult);
        Assert.areEqual(123, parsed.get('id'), 'JSON should contain id');
        Assert.areEqual('Ada', parsed.get('name'), 'JSON should contain name');
    }
    
    /**
     * Test TOON v3.0 decoding of list-item objects with tabular array as first field.
     * Per Section 10: tabular header on hyphen line, rows at depth +2, other fields at depth +1.
     */
    @IsTest
    private static void testDecodeListItemWithTabularFirstField() {
        // Given - v3.0 canonical form
        String toon = 'items[1]:\n  - users[2]{id,name}:\n      1,Ada\n      2,Bob\n    status: active';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        List<Object> items = (List<Object>) obj.get('items');
        Assert.areEqual(1, items.size(), 'Should have 1 item');
        
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        Assert.areEqual('active', firstItem.get('status'), 'Should have status field');
        
        List<Object> users = (List<Object>) firstItem.get('users');
        Assert.areEqual(2, users.size(), 'Should have 2 users');
        
        Map<String, Object> firstUser = (Map<String, Object>) users[0];
        Assert.areEqual(1L, firstUser.get('id'), 'First user id');
        Assert.areEqual('Ada', firstUser.get('name'), 'First user name');
        
        Map<String, Object> secondUser = (Map<String, Object>) users[1];
        Assert.areEqual(2L, secondUser.get('id'), 'Second user id');
        Assert.areEqual('Bob', secondUser.get('name'), 'Second user name');
    }
    
    /**
     * Test decoding empty object as list item (bare hyphen).
     */
    @IsTest
    private static void testDecodeEmptyListItemObject() {
        // Given
        String toon = 'items[2]:\n  -\n  - id: 1';

        // When
        Test.startTest();
        Object result = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> obj = (Map<String, Object>) result;
        List<Object> items = (List<Object>) obj.get('items');
        Assert.areEqual(2, items.size(), 'Should have 2 items');
        
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        Assert.isTrue(firstItem.isEmpty(), 'First item should be empty object');
        
        Map<String, Object> secondItem = (Map<String, Object>) items[1];
        Assert.areEqual(1L, secondItem.get('id'), 'Second item should have id');
    }
}
