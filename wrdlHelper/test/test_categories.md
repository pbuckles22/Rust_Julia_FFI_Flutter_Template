# 🧪 Test Categories and Data Requirements

## **Tier 1: Fast Unit Tests (90% of tests)**
**Data**: 200-300 curated words (comprehensive fallback list)
**Performance**: <1 second per test
**Use for**:
- ✅ UI component tests
- ✅ Service interaction tests  
- ✅ Business logic tests
- ✅ Visual feedback tests
- ✅ Error handling tests
- ✅ State management tests

**Setup**:
```dart
await GlobalTestSetup.initializeOnce(fastMode: true);
```

## **Tier 2: Algorithm Tests (5% of tests)**
**Data**: 1,000-2,000 strategic words
**Performance**: 2-5 seconds per test
**Use for**:
- ✅ Entropy calculation tests
- ✅ Statistical analysis tests
- ✅ Pattern simulation tests
- ✅ Word filtering tests
- ✅ Algorithm accuracy tests

**Setup**:
```dart
await GlobalTestSetup.initializeOnce(fastMode: false, algorithmMode: true);
```

## **Tier 3: Full Integration Tests (5% of tests)**
**Data**: Complete 17,169 word dataset
**Performance**: 5-10 seconds per test
**Use for**:
- ✅ Performance benchmarks
- ✅ End-to-end integration tests
- ✅ Production simulation tests
- ✅ Memory usage tests
- ✅ FFI bridge stress tests

**Setup**:
```dart
await GlobalTestSetup.initializeOnce(fastMode: false);
```

## **Test Naming Convention**

- `*_unit_test.dart` → Tier 1 (Fast Mode)
- `*_algorithm_test.dart` → Tier 2 (Algorithm Mode)  
- `*_integration_test.dart` → Tier 3 (Full Mode)
- `*_performance_test.dart` → Tier 3 (Full Mode)

## **When to Use Each Tier**

### **Use Tier 1 (Fast) When:**
- Testing UI components
- Testing service interactions
- Testing business logic
- Testing visual feedback
- Testing error handling
- Testing state management
- **Most unit tests** (90% of cases)

### **Use Tier 2 (Algorithm) When:**
- Testing entropy calculations
- Testing statistical analysis
- Testing pattern simulation
- Testing word filtering
- Testing algorithm accuracy
- **Algorithm validation tests** (5% of cases)

### **Use Tier 3 (Full) When:**
- Testing FFI performance
- Testing algorithm accuracy with full dataset
- Testing word filtering with large datasets
- Testing complete game flows
- **Integration/Performance tests** (5% of cases)

## **Performance Targets**

| Tier | Word Count | Load Time | Test Time | Use Case |
|------|------------|-----------|-----------|----------|
| 1 (Fast) | 200-300 | ~10ms | <1s | Unit tests |
| 2 (Algorithm) | 1,000-2,000 | ~50ms | 2-5s | Algorithm tests |
| 3 (Full) | 17,169 | ~2-3s | 5-10s | Integration tests |

## **Quality Gates**

- **Tier 1**: Must run in <1 second, 100% pass rate
- **Tier 2**: Must run in <5 seconds, 100% pass rate  
- **Tier 3**: Must run in <10 seconds, 100% pass rate
- **Overall**: All tests must pass, no hanging tests
