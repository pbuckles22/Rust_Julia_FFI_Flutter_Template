# 🚨 LINTING QUICK REFERENCE - CRITICAL INFORMATION

## **NEVER EDIT GENERATED FILES**

### **Files That Will Be Overwritten:**
- `lib/src/rust/frb_generated.dart` ❌ **NEVER EDIT**
- `lib/src/rust/frb_generated.io.dart` ❌ **NEVER EDIT**  
- `lib/src/rust/frb_generated.web.dart` ❌ **NEVER EDIT**
- `lib/src/rust/api/wrdl_helper.dart` ❌ **NEVER EDIT**

### **Files Safe to Edit:**
- `lib/services/` ✅ **SAFE TO EDIT**
- `lib/widgets/` ✅ **SAFE TO EDIT**
- `lib/models/` ✅ **SAFE TO EDIT**
- `lib/controllers/` ✅ **SAFE TO EDIT**
- `lib/exceptions/` ✅ **SAFE TO EDIT**
- `lib/state_management/` ✅ **SAFE TO EDIT**
- `lib/utils/` ✅ **SAFE TO EDIT**

## **Quick Commands:**

### **Count Issues (Manual Files Only):**
```bash
flutter analyze --no-fatal-infos 2>/dev/null | grep "linter_rule" | grep -v "lib/src/rust/" | wc -l
```

### **Get File Breakdown (Manual Files Only):**
```bash
flutter analyze --no-fatal-infos 2>/dev/null | grep "linter_rule" | grep -v "lib/src/rust/" | cut -d: -f1 | sort | uniq -c | sort -nr
```

### **Check if File is Generated:**
```bash
head -5 lib/src/rust/frb_generated.dart | grep -q "generated" && echo "GENERATED - SKIP" || echo "MANUAL - FIX"
```

## **Common Linter Rules:**

### **public_member_api_docs**
- **Fix**: Add `/// Documentation comment` above public members
- **Example**: `/// The main data field` above `final String data;`

### **prefer_expression_function_bodies**
- **Fix**: Convert `{ return value; }` to `=> value;`
- **Example**: `String getName() => name;`

### **type_annotate_public_apis**
- **Fix**: Add return type annotations to public methods
- **Example**: `String getValue() => value;`

### **avoid_catches_without_on_clauses**
- **Fix**: Add `on ExceptionType` to catch clauses
- **Example**: `on SpecificException catch (e) { ... }`

## **Linting Workflow:**

1. **Identify linter rule**: `flutter analyze | grep "rule_name"`
2. **Count total issues**: `wc -l` to get total count
3. **Focus on manual files**: Exclude generated files with `grep -v "lib/src/rust/"`
4. **Fix by file**: Work on one file at a time
5. **Verify progress**: Re-run linter after each file
6. **Commit frequently**: Commit after each significant batch

## **Documentation Requirements:**

### **Every Linting Session Must Document:**
- **Total issues found**: Before starting
- **Files excluded**: Generated files that were skipped
- **Issues fixed**: Number of issues resolved
- **Files modified**: List of files that were changed
- **Remaining issues**: Count of unfixed issues
- **Next steps**: What to tackle next

## **Troubleshooting:**

### **Common Issues:**
1. **Generated file confusion**: Always check file location and content
2. **Lost changes**: Never edit generated files
3. **Linter count mismatch**: Use proper exclusion filters
4. **Build failures**: Regenerate FFI bindings if needed

### **Verification:**
```bash
# Check file location
echo $file | grep -q "lib/src/rust/" && echo "GENERATED LOCATION - SKIP" || echo "MANUAL LOCATION - FIX"

# Check file content
head -5 $file | grep -q "generated" && echo "GENERATED - SKIP" || echo "MANUAL - FIX"
```

## **Remember:**
- **Generated files = 267 issues that should be ignored**
- **Manual files = Target for linting fixes**
- **Always use exclusion filters**: `grep -v "lib/src/rust/"`
- **Never edit generated files**: Changes will be lost
- **Focus on manual files only**: Services, widgets, models, controllers, exceptions

---

**For comprehensive guidelines, see `docs/CODE_STANDARDS.md`**
