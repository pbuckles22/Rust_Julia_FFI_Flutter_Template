# MICRO-STEP MIGRATION PLAN
## Centralizing Word List Management in Rust

**Goal:** Eliminate Flutter's interaction with word lists and ensure Flutter only uses FFI for all word-related operations, including validation.

**Approach:** TDD (Test-Driven Development) with micro-steps - one change at a time with testing after each step.

---

## 📋 **MICRO-STEP TODO LIST**

### **PHASE 1: Test FFI Functions (Steps 1-5)**
- [ ] **MICRO-STEP 1:** Test FfiService.isValidWord() with a single test case - Verify it returns true for valid words
- [ ] **MICRO-STEP 2:** Test FfiService.isValidWord() with invalid words - Verify it returns false for invalid words
- [ ] **MICRO-STEP 3:** Test FfiService.getAnswerWords() - Verify it returns the correct number of answer words
- [ ] **MICRO-STEP 4:** Test FfiService.getGuessWords() - Verify it returns the correct number of guess words
- [ ] **MICRO-STEP 5:** Verify all existing tests still pass - Run full test suite to ensure no regressions

### **PHASE 2: Test GameService Integration (Steps 6-11)**
- [ ] **MICRO-STEP 6:** Test GameService.isValidWord() calls FfiService.isValidWord() - Add one test case
- [ ] **MICRO-STEP 7:** Verify GameService.isValidWord() test passes - Run just that test
- [ ] **MICRO-STEP 8:** Test GameService word filtering uses Rust - Add one test case
- [ ] **MICRO-STEP 9:** Verify GameService word filtering test passes - Run just that test
- [ ] **MICRO-STEP 10:** Test GameService word selection uses Rust - Add one test case
- [ ] **MICRO-STEP 11:** Verify GameService word selection test passes - Run just that test

### **PHASE 3: Remove GameService Dependencies (Steps 12-16)**
- [ ] **MICRO-STEP 12:** Remove ONE _wordService reference from GameService - Start with smallest one
- [ ] **MICRO-STEP 13:** Test that ONE change works - Run GameService tests
- [ ] **MICRO-STEP 14:** Remove SECOND _wordService reference from GameService - Next smallest
- [ ] **MICRO-STEP 15:** Test that SECOND change works - Run GameService tests
- [ ] **MICRO-STEP 16:** Continue removing _wordService references one by one - Each with individual testing

### **PHASE 4: Simplify AppService (Steps 17-22)**
- [ ] **MICRO-STEP 17:** Test AppService.initialize() only calls FfiService.initialize() - Add one test
- [ ] **MICRO-STEP 18:** Verify AppService test passes - Run just that test
- [ ] **MICRO-STEP 19:** Remove WordService creation from AppService - One line at a time
- [ ] **MICRO-STEP 20:** Test AppService still works - Run AppService tests
- [ ] **MICRO-STEP 21:** Remove asset loading from AppService - One line at a time
- [ ] **MICRO-STEP 22:** Test AppService still works - Run AppService tests

### **PHASE 5: Update Test Files (Steps 23-28)**
- [ ] **MICRO-STEP 23:** Update ONE test file to use FFI - Start with smallest test file
- [ ] **MICRO-STEP 24:** Verify that ONE test file passes - Run just that test file
- [ ] **MICRO-STEP 25:** Continue updating test files one by one - Each with individual testing
- [ ] **MICRO-STEP 26:** Remove ONE import of WordService - Start with smallest file
- [ ] **MICRO-STEP 27:** Test that ONE import removal works - Run affected tests
- [ ] **MICRO-STEP 28:** Continue removing WordService imports one by one - Each with testing

### **PHASE 6: Delete WordService (Steps 29-30)**
- [ ] **MICRO-STEP 29:** Delete WordService file - After all references removed
- [ ] **MICRO-STEP 30:** Test all tests pass without WordService - Run full test suite

### **PHASE 7: Remove Asset References (Steps 31-33)**
- [ ] **MICRO-STEP 31:** Remove ONE asset reference - Start with smallest file
- [ ] **MICRO-STEP 32:** Test that ONE asset removal works - Run affected tests
- [ ] **MICRO-STEP 33:** Continue removing asset references one by one - Each with testing

### **PHASE 8: Verify Performance (Steps 34-35)**
- [ ] **MICRO-STEP 34:** Run 100-game benchmark - Verify performance maintained
- [ ] **MICRO-STEP 35:** Run 1000-game benchmark - Verify 99.8% success rate

---

## 🎯 **KEY PRINCIPLES**

1. **One Change at a Time** - Never make multiple changes without testing
2. **Test After Every Step** - Run tests to verify each change works
3. **Rollback Points** - Commit after each successful step
4. **Start Small** - Begin with the smallest, safest changes
5. **TDD Approach** - Red-Green-Refactor cycle for each change

## 🧪 **TDD STRATEGY FOR MIGRATION**

### **Test-Driven Development Approach:**
1. **✅ Accept failures** on tests that need to be removed/updated
2. **🔄 Refactor obsolete tests** to match the new centralized approach
3. **🗑️ Delete redundant tests** that are no longer needed (NO SKIPPING)

### **When We See Test Failures:**
- **If it's a test we want to keep:** Refactor it to use FFI instead of WordService
- **If it's a test that's now redundant:** **DELETE it entirely**
- **If it's a test we're not ready to fix:** Accept the failure temporarily

### **Test Migration Phases:**
- **Phase 1:** Add NEW tests for centralized FFI functions
- **Phase 2:** Update existing tests to use FFI instead of WordService
- **Phase 3:** Delete OLD tests that are no longer needed

---

## 📊 **CURRENT STATUS**

**Current State:** Flutter manages word lists in `WordService` (942 lines) + Rust manages word lists in `WordManager`
**Target State:** Only Rust manages word lists, Flutter uses FFI for all word operations
**Risk Level:** HIGH - Major architectural change affecting 38+ files
**Success Criteria:** 99.8% success rate maintained, <200ms response time, all tests pass

---

## 🔄 **ROLLBACK STRATEGY**

- Commit after each successful micro-step
- If any step fails, rollback to previous commit
- Never proceed to next step until current step is fully tested
- Keep detailed logs of what was changed in each step

---

## 📝 **NOTES**

- This migration eliminates the 942-line `WordService` file
- All word validation will go through Rust FFI
- Flutter will never reference `assets/word_lists/` again
- Performance must be maintained throughout migration
- Test coverage must remain at 100%

---

**Last Updated:** $(date)
**Current Step:** Ready to start MICRO-STEP 1
**Next Action:** Test FfiService.isValidWord() with a single test case
