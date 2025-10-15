# Test Standardization Template

## **🔧 STANDARD PATTERN TEMPLATE**

### **For Files WITH Existing Setup/Cleanup**
**Replace existing setup/cleanup with this pattern:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/service_locator.dart';

void main() {
  group('Test Group Name', () {
    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });
    
    tearDownAll(resetAllServices);
    
    // All existing tests here - NO CHANGES TO TEST LOGIC
  });
}
```

### **For Files WITHOUT Setup/Cleanup**
**Add this pattern after imports, before tests:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wrdlhelper/service_locator.dart';

void main() {
  group('Test Group Name', () {
    setUpAll(() async {
      // Initialize services with algorithm-testing word list
      await setupTestServices();
    });
    
    tearDownAll(resetAllServices);
    
    // All existing tests here - NO CHANGES TO TEST LOGIC
  });
}
```

---

## **📋 MIGRATION CHECKLIST**

### **Before Making Changes**
- [ ] Read the existing test file
- [ ] Identify current setup/cleanup pattern (if any)
- [ ] Note any special initialization requirements
- [ ] Verify the file is not generated (not in `lib/src/rust/`)

### **Making Changes**
- [ ] Add import: `import 'package:wrdlhelper/service_locator.dart';`
- [ ] Replace/Add `setUpAll()` with standard pattern
- [ ] Replace/Add `tearDownAll()` with standard pattern
- [ ] **DO NOT CHANGE** any existing test logic
- [ ] **DO NOT CHANGE** any test names or descriptions

### **After Making Changes**
- [ ] Run individual test file: `flutter test test/[file_name].dart`
- [ ] Verify no compilation errors
- [ ] Verify all tests pass
- [ ] Commit changes with clear message

---

## **🚨 CRITICAL RULES**

### **NEVER EDIT GENERATED FILES**
- ❌ `lib/src/rust/frb_generated.dart`
- ❌ `lib/src/rust/frb_generated.io.dart`
- ❌ `lib/src/rust/frb_generated.web.dart`
- ❌ `lib/src/rust/api/wrdl_helper.dart`
- ❌ Any file with `@generated` comment

### **ALWAYS PRESERVE TEST LOGIC**
- ✅ Keep all existing test code unchanged
- ✅ Keep all test names and descriptions
- ✅ Keep all test assertions and expectations
- ✅ Only change setup/cleanup patterns

### **VERIFY AFTER EACH CHANGE**
- ✅ Run individual test file
- ✅ Check for compilation errors
- ✅ Ensure all tests pass
- ✅ Commit with clear message

---

## **📝 COMMIT MESSAGE TEMPLATE**

```
test: standardize setup/cleanup in [file_name].dart

- Replace [old_pattern] with standard service locator pattern
- Add proper setup/cleanup for test isolation
- Maintain all existing test logic and functionality
- Verify: flutter test test/[file_name].dart passes
```

---

**Last Updated**: January 2025  
**Status**: Template Ready for Use  
**Next Step**: Begin systematic migration with this template
