/**
 * Test class for ToonTypeHelper.
 */
@IsTest
private class ToonTypeHelperTest {
    
    @IsTest
    private static void testIsPrimitive_Null() {
        // Given
        Object value = null;

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isPrimitive(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Null should be primitive');
    }
    
    @IsTest
    private static void testIsPrimitive_Boolean() {
        // Given
        Object value = true;

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isPrimitive(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Boolean should be primitive');
    }
    
    @IsTest
    private static void testIsPrimitive_Integer() {
        // Given
        Object value = 123;

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isPrimitive(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Integer should be primitive');
    }
    
    @IsTest
    private static void testIsPrimitive_String() {
        // Given
        Object value = 'hello';

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isPrimitive(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'String should be primitive');
    }
    
    @IsTest
    private static void testIsPrimitive_Decimal() {
        // Given
        Object value = 3.14;

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isPrimitive(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Decimal should be primitive');
    }
    
    @IsTest
    private static void testIsPrimitive_List() {
        // Given
        Object value = new List<Object>{ 1, 2, 3 };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isPrimitive(value);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'List should not be primitive');
    }
    
    @IsTest
    private static void testIsPrimitive_Map() {
        // Given
        Object value = new Map<String, Object>{ 'key' => 'value' };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isPrimitive(value);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Map should not be primitive');
    }
    
    @IsTest
    private static void testIsList() {
        // Given
        Object value = new List<Object>{ 1, 2, 3 };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isList(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Should identify List');
    }
    
    @IsTest
    private static void testIsList_NotList() {
        // Given
        Object value = new Map<String, Object>();

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isList(value);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Map should not be List');
    }
    
    @IsTest
    private static void testIsMap() {
        // Given
        Object value = new Map<String, Object>{ 'key' => 'value' };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isMap(value);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Should identify Map');
    }
    
    @IsTest
    private static void testIsMap_NotMap() {
        // Given
        Object value = new List<Object>();

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isMap(value);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'List should not be Map');
    }
    
    @IsTest
    private static void testGetTypeName_Primitives() {
        // Given / When
        Test.startTest();
        String nullType = ToonTypeHelper.getTypeName(null);
        String boolType = ToonTypeHelper.getTypeName(true);
        String intType = ToonTypeHelper.getTypeName(123);
        String strType = ToonTypeHelper.getTypeName('test');
        Test.stopTest();

        // Then
        Assert.areEqual('null', nullType, 'Should identify null');
        Assert.areEqual('Boolean', boolType, 'Should identify Boolean');
        Assert.areEqual('Integer', intType, 'Should identify Integer');
        Assert.areEqual('String', strType, 'Should identify String');
    }
    
    @IsTest
    private static void testGetTypeName_Collections() {
        // Given / When
        Test.startTest();
        String listType = ToonTypeHelper.getTypeName(new List<Object>());
        String mapType = ToonTypeHelper.getTypeName(new Map<String, Object>());
        Test.stopTest();

        // Then
        Assert.areEqual('List', listType, 'Should identify List');
        Assert.areEqual('Map', mapType, 'Should identify Map');
    }
    
    @IsTest
    private static void testAreAllPrimitives_True() {
        // Given
        List<Object> items = new List<Object>{ 1, 'two', 3.0, true, null };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.areAllPrimitives(items);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'All items should be primitives');
    }
    
    @IsTest
    private static void testAreAllPrimitives_False() {
        // Given
        List<Object> items = new List<Object>{ 1, 2, new Map<String, Object>() };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.areAllPrimitives(items);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Not all items are primitives');
    }
    
    @IsTest
    private static void testAreAllPrimitives_Empty() {
        // Given
        List<Object> items = new List<Object>();

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.areAllPrimitives(items);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Empty list should return true');
    }
    
    @IsTest
    private static void testAreAllMaps_True() {
        // Given
        List<Object> items = new List<Object>{
            new Map<String, Object>{ 'a' => 1 },
            new Map<String, Object>{ 'b' => 2 }
        };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.areAllMaps(items);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'All items should be Maps');
    }
    
    @IsTest
    private static void testAreAllMaps_False() {
        // Given
        List<Object> items = new List<Object>{
            new Map<String, Object>(),
            'not a map'
        };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.areAllMaps(items);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Not all items are Maps');
    }
    
    @IsTest
    private static void testHaveUniformKeys_True() {
        // Given
        List<Object> items = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Alice' },
            new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
        };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.haveUniformKeys(items);
        Test.stopTest();

        // Then
        Assert.areEqual(true, result, 'Items should have uniform keys');
    }
    
    @IsTest
    private static void testHaveUniformKeys_False() {
        // Given
        List<Object> items = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Alice' },
            new Map<String, Object>{ 'id' => 2, 'age' => 30 }
        };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.haveUniformKeys(items);
        Test.stopTest();

        // Then
        Assert.areEqual(false, result, 'Items should not have uniform keys');
    }
    
    @IsTest
    private static void testGetUniformKeys() {
        // Given
        List<Object> items = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Alice' },
            new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
        };

        // When
        Test.startTest();
        List<String> keys = ToonTypeHelper.getUniformKeys(items);
        Test.stopTest();

        // Then
        Assert.areEqual(2, keys.size(), 'Should return 2 keys');
        Assert.isTrue(keys.contains('id'), 'Should contain id');
        Assert.isTrue(keys.contains('name'), 'Should contain name');
    }
    
    @IsTest
    private static void testGetUniformKeys_Empty() {
        // Given
        List<Object> items = new List<Object>();

        // When
        Test.startTest();
        List<String> keys = ToonTypeHelper.getUniformKeys(items);
        Test.stopTest();

        // Then
        Assert.areEqual(0, keys.size(), 'Should return empty list');
    }
    
    // ===============================
    // isTabularArray Tests (v3.0)
    // ===============================
    
    @IsTest
    private static void testIsTabularArray_UniformMapsWithPrimitives() {
        // Given - uniform maps with only primitive values
        List<Object> items = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Ada' },
            new Map<String, Object>{ 'id' => 2, 'name' => 'Bob' }
        };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isTabularArray(items);
        Test.stopTest();

        // Then
        Assert.isTrue(result, 'Should be tabular array');
    }
    
    @IsTest
    private static void testIsTabularArray_NonUniformKeys() {
        // Given - maps with different keys
        List<Object> items = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'name' => 'Ada' },
            new Map<String, Object>{ 'id' => 2, 'email' => 'bob@example.com' }
        };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isTabularArray(items);
        Test.stopTest();

        // Then
        Assert.isFalse(result, 'Should not be tabular array with non-uniform keys');
    }
    
    @IsTest
    private static void testIsTabularArray_NestedObjects() {
        // Given - maps with nested objects (not primitive-only)
        List<Object> items = new List<Object>{
            new Map<String, Object>{ 'id' => 1, 'meta' => new Map<String, Object>{ 'x' => 1 } },
            new Map<String, Object>{ 'id' => 2, 'meta' => new Map<String, Object>{ 'x' => 2 } }
        };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isTabularArray(items);
        Test.stopTest();

        // Then
        Assert.isFalse(result, 'Should not be tabular array with nested objects');
    }
    
    @IsTest
    private static void testIsTabularArray_EmptyList() {
        // Given
        List<Object> items = new List<Object>();

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isTabularArray(items);
        Test.stopTest();

        // Then
        Assert.isFalse(result, 'Empty list should not be tabular array');
    }
    
    @IsTest
    private static void testIsTabularArray_NotAList() {
        // Given
        Object value = 'not a list';

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isTabularArray(value);
        Test.stopTest();

        // Then
        Assert.isFalse(result, 'Non-list should not be tabular array');
    }
    
    @IsTest
    private static void testIsTabularArray_PrimitivesList() {
        // Given - list of primitives (not maps)
        List<Object> items = new List<Object>{ 1, 2, 3 };

        // When
        Test.startTest();
        Boolean result = ToonTypeHelper.isTabularArray(items);
        Test.stopTest();

        // Then
        Assert.isFalse(result, 'List of primitives should not be tabular array');
    }
}
