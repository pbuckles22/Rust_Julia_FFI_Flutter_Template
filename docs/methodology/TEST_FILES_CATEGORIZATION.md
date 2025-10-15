# Test Files Categorization by Complexity

## **📊 CATEGORIZATION SUMMARY**

**Total Files**: 68  
**Simple Files**: 25 (2-3 min each)  
**Medium Files**: 30 (3-5 min each)  
**Complex Files**: 13 (5-10 min each)  

---

## **🟢 SIMPLE FILES (25 files) - 2-3 min each**

### **Widget Tests (15 files)**
- `widgets/simple_widget_test.dart` - Basic widget rendering
- `widgets/letter_tile_test.dart` - Simple letter tile tests
- `widgets/letter_tile_tdd_test.dart` - TDD letter tile tests
- `widgets/game_status_test.dart` - Game status display
- `widgets/game_grid_test.dart` - Game grid functionality
- `widgets/game_controls_test.dart` - Game control buttons
- `widgets/virtual_keyboard_test.dart` - Virtual keyboard (already fixed)
- `widgets/virtual_keyboard_tdd_test.dart` - TDD virtual keyboard
- `widgets/game_grid_tdd_test.dart` - TDD game grid (already fixed)
- `visual_feedback/visual_feedback_reliability_test.dart` - Visual feedback
- `visual_feedback/visual_feedback_persistence_test.dart` - Visual feedback persistence
- `screens/wordle_game_screen_test.dart` - Main game screen
- `integration/wordle_screen_service_locator_integration_test.dart` - Screen integration
- `integration/main_service_locator_integration_test.dart` - Service locator integration
- `integration/main_app_test.dart` - Main app integration

### **Model Tests (5 files)**
- `models/guess_result_test.dart` - Guess result model
- `models/game_state_test.dart` - Game state model
- `models/word_model_test.dart` - Word model
- `controllers/game_controller_test.dart` - Game controller
- `state_management/game_state_manager_test.dart` - State management

### **Simple Unit Tests (5 files)**
- `wrdl_helper_test.dart` - Basic helper tests
- `word_filtering_bug_test.dart` - Word filtering
- `ultra_simple_test.dart` - Ultra simple tests
- `simple_debug_test.dart` - Simple debug tests
- `core_functionality_test.dart` - Core functionality

---

## **🟡 MEDIUM FILES (30 files) - 3-5 min each**

### **Service Tests (15 files)**
- `services/game_service_test.dart` - Game service tests
- `services/game_service_ffi_integration_test.dart` - Game service FFI integration
- `services/ffi_service_test.dart` - FFI service tests
- `services/ffi_answer_generator_test.dart` - FFI answer generator
- `services/ffi_service_basic_functions_test.dart` - FFI basic functions
- `services/ffi_service_configuration_test.dart` - FFI configuration
- `services/ffi_service_error_handling_test.dart` - FFI error handling
- `services/ffi_service_guess_functions_test.dart` - FFI guess functions
- `services/ffi_service_performance_test.dart` - FFI performance
- `services/ffi_service_reference_mode_test.dart` - FFI reference mode
- `services/ffi_service_validation_test.dart` - FFI validation
- `services/ffi_usage_analysis_test.dart` - FFI usage analysis
- `services/ffi_performance_test.dart` - FFI performance
- `services/ffi_config_test.dart` - FFI configuration
- `services/mock_services_test.dart` - Mock services

### **Integration Tests (10 files)**
- `integration/widget_test.dart` - Widget integration
- `integration/service_locator_integration_test.dart` - Service locator integration
- `integration/game_integration_test.dart` - Game integration
- `integration/complete_game_flow_test.dart` - Complete game flow
- `integration/basic_integration_test.dart` - Basic integration
- `word_list_sync_test.dart` - Word list synchronization
- `word_list_parity_test.dart` - Word list parity
- `filtering_parity_test.dart` - Filtering parity
- `candidate_pool_controls_test.dart` - Candidate pool controls
- `asset_loading_test.dart` - Asset loading

### **Algorithm Tests (5 files)**
- `simple_algorithm_test.dart` - Simple algorithm tests
- `multiple_algorithm_test.dart` - Multiple algorithm tests
- `game_controller_basic_test.dart` - Game controller basic
- `entropy_mode_test.dart` - Entropy mode
- `killer_words_test.dart` - Killer words

---

## **🔴 COMPLEX FILES (13 files) - 5-10 min each**

### **Performance Tests (8 files)**
- `statistical_benchmark_test.dart` - Statistical benchmark (200 games)
- `centralized_ffi_benchmark_test.dart` - Centralized FFI benchmark (500 games)
- `comprehensive_performance_test.dart` - Comprehensive performance
- `solver_benchmark_test.dart` - Solver benchmark
- `rust_vs_flutter_benchmark_test.dart` - Rust vs Flutter benchmark
- `performance/performance_test.dart` - Performance tests
- `performance/main_screen_performance_test.dart` - Main screen performance
- `memory_stress_test.dart` - Memory stress tests

### **Integration Tests (3 files)**
- `benchmark_integration_test.dart` - Benchmark integration
- `code_quality_improvements_test.dart` - Code quality improvements
- `project_setup_test.dart` - Project setup
- `project_rename_test.dart` - Project rename

### **Special Cases (2 files)**
- `pubspec_configuration_test.dart` - Pubspec configuration
- `iphone_performance_test.dart` - iPhone performance (has syntax errors)

---

## **📋 BATCH PROCESSING PLAN**

### **Batch 1: Simple Widget Tests (15 files) - 30 min**
- **Time per file**: 2 min
- **Risk level**: Low
- **Verification**: Run individual tests after each file

### **Batch 2: Simple Model/Unit Tests (10 files) - 20 min**
- **Time per file**: 2 min
- **Risk level**: Low
- **Verification**: Run individual tests after each file

### **Batch 3: Medium Service Tests (15 files) - 45 min**
- **Time per file**: 3 min
- **Risk level**: Medium
- **Verification**: Run individual tests after each file

### **Batch 4: Medium Integration Tests (10 files) - 30 min**
- **Time per file**: 3 min
- **Risk level**: Medium
- **Verification**: Run individual tests after each file

### **Batch 5: Medium Algorithm Tests (5 files) - 20 min**
- **Time per file**: 4 min
- **Risk level**: Medium
- **Verification**: Run individual tests after each file

### **Batch 6: Complex Performance Tests (8 files) - 60 min**
- **Time per file**: 7-8 min
- **Risk level**: High
- **Verification**: Run individual tests after each file

### **Batch 7: Complex Integration Tests (4 files) - 30 min**
- **Time per file**: 7-8 min
- **Risk level**: High
- **Verification**: Run individual tests after each file

### **Batch 8: Special Cases (2 files) - 15 min**
- **Time per file**: 7-8 min
- **Risk level**: High
- **Verification**: Run individual tests after each file

---

## **🎯 TOTAL TIME ESTIMATE**

**Simple Files**: 25 × 2 min = 50 min  
**Medium Files**: 30 × 4 min = 120 min  
**Complex Files**: 13 × 8 min = 104 min  
**Total**: ~4.5 hours  

**With verification and testing**: ~5-6 hours total

---

**Last Updated**: January 2025  
**Status**: Categorization Complete - Ready for Migration  
**Next Step**: Begin Batch 1 - Simple Widget Tests
