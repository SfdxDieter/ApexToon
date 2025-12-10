/**
 * Round-trip tests for ApexToon.
 * Verifies that encode → decode produces equivalent structures.
 */
@IsTest
private class ApexToonRoundTripTest {
    
    @IsTest
    private static void testRoundTripPrimitiveNull() {
        // Given
        Object original = null;

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(original, decoded, 'Round-trip should preserve null');
    }
    
    @IsTest
    private static void testRoundTripPrimitiveBoolean() {
        // Given
        Boolean original = true;

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(original, decoded, 'Round-trip should preserve boolean');
    }
    
    @IsTest
    private static void testRoundTripPrimitiveInteger() {
        // Given
        Integer original = 42;

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual((Long)original, decoded, 'Round-trip should preserve integer');
    }
    
    @IsTest
    private static void testRoundTripPrimitiveDecimal() {
        // Given
        Decimal original = 3.14;

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(original, decoded, 'Round-trip should preserve decimal');
    }
    
    @IsTest
    private static void testRoundTripPrimitiveString() {
        // Given
        String original = 'hello world';

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(original, decoded, 'Round-trip should preserve string');
    }
    
    @IsTest
    private static void testRoundTripStringWithSpecialChars() {
        // Given
        String original = 'line1\nline2\t"quoted"';

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Assert.areEqual(original, decoded, 'Round-trip should preserve special characters');
    }
    
    @IsTest
    private static void testRoundTripSimpleObject() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'id' => 123,
            'name' => 'Ada',
            'active' => true
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Assert.areEqual(123L, result.get('id'), 'Should preserve id');
        Assert.areEqual('Ada', result.get('name'), 'Should preserve name');
        Assert.areEqual(true, result.get('active'), 'Should preserve active');
    }
    
    @IsTest
    private static void testRoundTripNestedObject() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'id' => 1,
            'user' => new Map<String, Object>{
                'name' => 'Alice',
                'age' => 30
            }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Assert.areEqual(1L, result.get('id'), 'Should preserve id');
        
        Map<String, Object> user = (Map<String, Object>) result.get('user');
        Assert.areEqual('Alice', user.get('name'), 'Should preserve nested name');
        Assert.areEqual(30L, user.get('age'), 'Should preserve nested age');
    }
    
    @IsTest
    private static void testRoundTripPrimitiveArray() {
        // Given
        List<Object> original = new List<Object>{ 'admin', 'ops', 'dev' };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> result = (List<Object>) decoded;
        Assert.areEqual(3, result.size(), 'Should preserve array length');
        Assert.areEqual('admin', result[0], 'Should preserve first item');
        Assert.areEqual('ops', result[1], 'Should preserve second item');
        Assert.areEqual('dev', result[2], 'Should preserve third item');
    }
    
    @IsTest
    private static void testRoundTripTabularArray() {
        // Given
        List<Object> original = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Alice' },
            new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> result = (List<Object>) decoded;
        Assert.areEqual(2, result.size(), 'Should preserve array length');
        
        Map<String, Object> first = (Map<String, Object>) result[0];
        Assert.areEqual(1L, first.get('id'), 'Should preserve first row id');
        Assert.areEqual('Alice', first.get('name'), 'Should preserve first row name');
        
        Map<String, Object> second = (Map<String, Object>) result[1];
        Assert.areEqual(2L, second.get('id'), 'Should preserve second row id');
        Assert.areEqual('Bob', second.get('name'), 'Should preserve second row name');
    }
    
    @IsTest
    private static void testRoundTripObjectWithArray() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'user' => 'Alice',
            'tags' => new List<Object>{ 'admin', 'dev' }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Assert.areEqual('Alice', result.get('user'), 'Should preserve user');
        
        List<Object> tags = (List<Object>) result.get('tags');
        Assert.areEqual(2, tags.size(), 'Should preserve tags length');
        Assert.areEqual('admin', tags[0], 'Should preserve first tag');
        Assert.areEqual('dev', tags[1], 'Should preserve second tag');
    }
    
    @IsTest
    private static void testRoundTripMixedArray() {
        // Given
        List<Object> original = new List<Object>{
            'string',
            123,
            new Map<String, Object>{ 'key' => 'value' }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> result = (List<Object>) decoded;
        Assert.areEqual(3, result.size(), 'Should preserve array length');
        Assert.areEqual('string', result[0], 'Should preserve string item');
        Assert.areEqual(123L, result[1], 'Should preserve number item');
        
        Map<String, Object> obj = (Map<String, Object>) result[2];
        Assert.areEqual('value', obj.get('key'), 'Should preserve object item');
    }
    
    @IsTest
    private static void testRoundTripComplexNested() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'project' => 'ApexToon',
            'version' => '0.1.0',
            'metadata' => new Map<String, Object>{
                'author' => 'Team',
                'tags' => new List<Object>{ 'apex', 'toon', 'encoding' }
            },
            'items' => new List<Object>{
                new Map<String, Object>{ 'id' => 1, 'status' => 'active' },
                new Map<String, Object>{ 'id' => 2, 'status' => 'pending' }
            }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Assert.areEqual('ApexToon', result.get('project'), 'Should preserve project');
        Assert.areEqual('0.1.0', result.get('version'), 'Should preserve version');
        
        Map<String, Object> metadata = (Map<String, Object>) result.get('metadata');
        Assert.areEqual('Team', metadata.get('author'), 'Should preserve nested author');
        
        List<Object> tags = (List<Object>) metadata.get('tags');
        Assert.areEqual(3, tags.size(), 'Should preserve nested array length');
        
        List<Object> items = (List<Object>) result.get('items');
        Assert.areEqual(2, items.size(), 'Should preserve items array length');
    }
    
    @IsTest
    private static void testRoundTripEmptyObject() {
        // Given
        Map<String, Object> original = new Map<String, Object>();

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Assert.areEqual(0, result.size(), 'Should preserve empty object');
    }
    
    @IsTest
    private static void testRoundTripEmptyArray() {
        // Given
        List<Object> original = new List<Object>();

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        List<Object> result = (List<Object>) decoded;
        Assert.areEqual(0, result.size(), 'Should preserve empty array');
    }
    
    @IsTest
    private static void testRoundTripJsonBridge() {
        // Given
        String originalJson = '{"id":123,"name":"Ada","tags":["admin","dev"]}';

        // When
        Test.startTest();
        String toon = ApexToon.encodeJson(originalJson);
        String resultJson = ApexToon.decodeToJson(toon);
        Test.stopTest();

        // Then
        Map<String, Object> original = (Map<String, Object>) JSON.deserializeUntyped(originalJson);
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        
        Assert.areEqual(original.get('id'), result.get('id'), 'JSON round-trip should preserve id');
        Assert.areEqual(original.get('name'), result.get('name'), 'JSON round-trip should preserve name');
    }
    
    @IsTest
    private static void testRoundTripWithCustomOptions() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'id' => 1,
            'nested' => new Map<String, Object>{
                'value' => 'test'
            }
        };
        EncodeOptions encodeOpts = new EncodeOptions(4, ToonDelimiter.COMMA);
        DecodeOptions decodeOpts = new DecodeOptions();

        // When
        Test.startTest();
        String toon = ApexToon.encode(original, encodeOpts);
        Object decoded = ApexToon.decode(toon, decodeOpts);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Assert.areEqual(1L, result.get('id'), 'Should preserve with custom options');
        
        Map<String, Object> nested = (Map<String, Object>) result.get('nested');
        Assert.areEqual('test', nested.get('value'), 'Should preserve nested value');
    }
    
    @IsTest
    private static void testRoundTripDeepNesting() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'level1' => new Map<String, Object>{
                'level2' => new Map<String, Object>{
                    'level3' => new Map<String, Object>{
                        'value' => 'deep'
                    }
                }
            }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        Map<String, Object> level1 = (Map<String, Object>) result.get('level1');
        Map<String, Object> level2 = (Map<String, Object>) level1.get('level2');
        Map<String, Object> level3 = (Map<String, Object>) level2.get('level3');
        Assert.areEqual('deep', level3.get('value'), 'Should preserve deep nesting');
    }
    
    /**
     * Test TOON v3.0 round-trip for list-item objects with tabular array as first field.
     */
    @IsTest
    private static void testRoundTripListItemWithTabularFirstField() {
        // Given - list item object with tabular array as first field
        Map<String, Object> original = new Map<String, Object>{
            'items' => new List<Object>{
                new Map<String, Object>{
                    'users' => new List<Object>{
                        new Map<String, Object>{ 'id' => 1, 'name' => 'Ada' },
                        new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
                    },
                    'status' => 'active'
                },
                new Map<String, Object>{
                    'users' => new List<Object>{
                        new Map<String, Object>{ 'id' => 3, 'name' => 'Charlie' }
                    },
                    'status' => 'pending'
                }
            }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        List<Object> items = (List<Object>) result.get('items');
        Assert.areEqual(2, items.size(), 'Should preserve items count');
        
        // First item
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        Assert.areEqual('active', firstItem.get('status'), 'Should preserve first item status');
        List<Object> firstUsers = (List<Object>) firstItem.get('users');
        Assert.areEqual(2, firstUsers.size(), 'Should preserve first users count');
        
        // Second item  
        Map<String, Object> secondItem = (Map<String, Object>) items[1];
        Assert.areEqual('pending', secondItem.get('status'), 'Should preserve second item status');
        List<Object> secondUsers = (List<Object>) secondItem.get('users');
        Assert.areEqual(1, secondUsers.size(), 'Should preserve second users count');
    }
    
    /**
     * Test round-trip for empty object as list item.
     */
    @IsTest
    private static void testRoundTripEmptyListItemObject() {
        // Given
        Map<String, Object> original = new Map<String, Object>{
            'items' => new List<Object>{
                new Map<String, Object>(),
                new Map<String, Object>{ 'id' => 1 }
            }
        };

        // When
        Test.startTest();
        String toon = ApexToon.encode(original);
        Object decoded = ApexToon.decode(toon);
        Test.stopTest();

        // Then
        Map<String, Object> result = (Map<String, Object>) decoded;
        List<Object> items = (List<Object>) result.get('items');
        Assert.areEqual(2, items.size(), 'Should preserve items count');
        
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        Assert.areEqual(0, firstItem.size(), 'Should preserve empty object');
        
        Map<String, Object> secondItem = (Map<String, Object>) items[1];
        Assert.areEqual(1L, secondItem.get('id'), 'Should preserve second item');
    }
}
