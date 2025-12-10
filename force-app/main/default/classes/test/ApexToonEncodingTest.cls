/**
 * Integration tests for ApexToon encoding.
 * Tests the complete encoding pipeline from ApexToon.encode() down.
 */
@IsTest
private class ApexToonEncodingTest {
    
    @IsTest
    private static void testEncodePrimitiveNull() {
        // Given
        Object value = null;

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('null', result, 'Should encode null');
    }
    
    @IsTest
    private static void testEncodePrimitiveBoolean() {
        // Given
        Boolean value = true;

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('true', result, 'Should encode boolean');
    }
    
    @IsTest
    private static void testEncodePrimitiveNumber() {
        // Given
        Integer value = 42;

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('42', result, 'Should encode number');
    }
    
    @IsTest
    private static void testEncodePrimitiveString() {
        // Given
        String value = 'hello';

        // When
        Test.startTest();
        String result = ApexToon.encode(value);
        Test.stopTest();

        // Then
        Assert.areEqual('hello', result, 'Should encode string');
    }
    
    @IsTest
    private static void testEncodeSimpleObject() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'id' => 123,
            'name' => 'Ada',
            'active' => true
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('id: 123'), 'Should contain id field');
        Assert.isTrue(result.contains('name: Ada'), 'Should contain name field');
        Assert.isTrue(result.contains('active: true'), 'Should contain active field');
    }
    
    @IsTest
    private static void testEncodeNestedObject() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'id' => 1,
            'user' => new Map<String, Object>{
                'name' => 'Alice',
                'age' => 30
            }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('id: 1'), 'Should contain id');
        Assert.isTrue(result.contains('user:'), 'Should contain user key');
        Assert.isTrue(result.contains('name: Alice'), 'Should contain nested name');
        Assert.isTrue(result.contains('age: 30'), 'Should contain nested age');
    }
    
    @IsTest
    private static void testEncodePrimitiveArray() {
        // Given
        List<Object> arrayResult = new List<Object>{ 'admin', 'ops', 'dev' };

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.isTrue(result.startsWith('[3]:'), 'Should have arrayResult header');
        Assert.isTrue(result.contains('admin'), 'Should contain first item');
        Assert.isTrue(result.contains('ops'), 'Should contain second item');
        Assert.isTrue(result.contains('dev'), 'Should contain third item');
    }
    
    @IsTest
    private static void testEncodeTabularArray() {
        // Given
        List<Object> arrayResult = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Alice' },
            new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('[2]{'), 'Should have tabular header with length');
        Assert.isTrue(result.contains('id'), 'Should contain id field in header');
        Assert.isTrue(result.contains('name'), 'Should contain name field in header');
        Assert.isTrue(result.contains('1'), 'Should contain first row data');
        Assert.isTrue(result.contains('Alice'), 'Should contain first row name');
        Assert.isTrue(result.contains('2'), 'Should contain second row data');
        Assert.isTrue(result.contains('Bob'), 'Should contain second row name');
    }
    
    @IsTest
    private static void testEncodeObjectWithArray() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'user' => 'Alice',
            'tags' => new List<Object>{ 'admin', 'dev' }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('user: Alice'), 'Should contain user field');
        Assert.isTrue(result.contains('tags[2]:'), 'Should contain tags arrayResult header');
        Assert.isTrue(result.contains('admin'), 'Should contain tag value');
        Assert.isTrue(result.contains('dev'), 'Should contain tag value');
    }
    
    @IsTest
    private static void testEncodeWithCustomOptions() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'id' => 1,
            'nested' => new Map<String, Object>{
                'value' => 'test'
            }
        };
        EncodeOptions options = new EncodeOptions(4, ToonDelimiter.COMMA);

        // When
        Test.startTest();
        String result = ApexToon.encode(obj, options);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('nested:'), 'Should contain nested key');
        Assert.isTrue(result.contains('    value: test'), 'Should use 4-space indentation');
    }
    
    @IsTest
    private static void testEncodeJson() {
        // Given
        String jsonStr = '{"id":123,"name":"Ada"}';

        // When
        Test.startTest();
        String result = ApexToon.encodeJson(jsonStr);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('id: 123'), 'Should contain id');
        Assert.isTrue(result.contains('name: Ada'), 'Should contain name');
    }
    
    @IsTest
    private static void testEncodeEmptyObject() {
        // Given
        Map<String, Object> obj = new Map<String, Object>();

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.areEqual('', result, 'Empty object should produce empty string');
    }
    
    @IsTest
    private static void testEncodeEmptyArray() {
        // Given
        List<Object> arrayResult = new List<Object>();

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.areEqual('[0]:', result, 'Empty arrayResult should have zero length header');
    }
    
    @IsTest
    private static void testEncodeMixedArray() {
        // Given
        List<Object> arrayResult = new List<Object>{
            'string',
            123,
            new Map<String, Object>{ 'key' => 'value' }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(arrayResult);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('[3]:'), 'Should have list header');
        Assert.isTrue(result.contains('- string'), 'Should contain string item');
        Assert.isTrue(result.contains('- 123'), 'Should contain number item');
        Assert.isTrue(result.contains('- key: value'), 'Should contain object item');
    }
    
    @IsTest
    private static void testEncodeComplexNested() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'project' => 'TOON',
            'metadata' => new Map<String, Object>{
                'version' => '1.0',
                'authors' => new List<Object>{ 'Alice', 'Bob' }
            },
            'items' => new List<Object>{
                new Map<String, Object>{ 'id' => 1, 'status' => 'active' },
                new Map<String, Object>{ 'id' => 2, 'status' => 'pending' }
            }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('project: TOON'), 'Should contain project');
        Assert.isTrue(result.contains('metadata:'), 'Should contain metadata');
        Assert.isTrue(result.contains('version:'), 'Should contain version');
        Assert.isTrue(result.contains('authors'), 'Should contain authors arrayResult');
        Assert.isTrue(result.contains('items'), 'Should contain items tabular arrayResult');
        Assert.isTrue(result.contains('active'), 'Should contain status value');
    }
    
    /**
     * Test TOON v3.0 canonical form for list-item objects with tabular array as first field.
     * Per Section 10: tabular header on hyphen line, rows at depth +2, other fields at depth +1.
     */
    @IsTest
    private static void testEncodeListItemWithTabularFirstField() {
        // Given - list item object with tabular array as first field
        Map<String, Object> obj = new Map<String, Object>{
            'items' => new List<Object>{
                new Map<String, Object>{
                    'users' => new List<Object>{
                        new Map<String, Object>{ 'id' => 1, 'name' => 'Ada' },
                        new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
                    },
                    'status' => 'active'
                }
            }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then - verify v3.0 canonical form
        Assert.isTrue(result.contains('items[1]:'), 'Should have items array header');
        Assert.isTrue(result.contains('- users[2]{id,name}:'), 'Should have tabular header on hyphen line');
        Assert.isTrue(result.contains('1,Ada'), 'Should have first tabular row');
        Assert.isTrue(result.contains('2,Bob'), 'Should have second tabular row');
        Assert.isTrue(result.contains('status: active'), 'Should have sibling field');
        
        // Verify depth structure: tabular rows should be at depth +2 (4 spaces from hyphen line)
        String[] lines = result.split('\n');
        Boolean foundTabularRow = false;
        Boolean foundSiblingField = false;
        for (String line : lines) {
            if (line.contains('1,Ada') || line.contains('2,Bob')) {
                Assert.isTrue(line.startsWith('      '), 'Tabular rows should be at depth +2 (6 spaces)');
                foundTabularRow = true;
            }
            if (line.contains('status: active')) {
                Assert.isTrue(line.startsWith('    ') && !line.startsWith('      '), 'Sibling field should be at depth +1 (4 spaces)');
                foundSiblingField = true;
            }
        }
        Assert.isTrue(foundTabularRow, 'Should find tabular row with correct indentation');
        Assert.isTrue(foundSiblingField, 'Should find sibling field with correct indentation');
    }
    
    /**
     * Test empty object as list item uses bare hyphen per TOON v3.0.
     */
    @IsTest
    private static void testEncodeEmptyListItemObject() {
        // Given
        Map<String, Object> obj = new Map<String, Object>{
            'items' => new List<Object>{
                new Map<String, Object>()
            }
        };

        // When
        Test.startTest();
        String result = ApexToon.encode(obj);
        Test.stopTest();

        // Then
        Assert.isTrue(result.contains('items[1]:'), 'Should have items array header');
        Assert.isTrue(result.contains('  -'), 'Should have bare hyphen for empty object');
        Assert.isFalse(result.contains('- {}'), 'Should NOT use curly braces for empty object');
    }
}
