CC ?= gcc
AR ?= ar
JAVA ?= java
KOTLINC ?= kotlinc
GRADLE ?= gradle

CPPFLAGS ?=
CPPFLAGS += -Iinclude -Igenerated
CFLAGS ?= -O2
CFLAGS += -std=c11 -Wall -Wextra -Wpedantic
JNI_CFLAGS ?= -fPIC

BUILD_DIR := build
LIB_DIR := lib
ADAPTER_OBJ := $(BUILD_DIR)/kotlin_polycall.o
STATIC_LIB := $(LIB_DIR)/libkotlin_polycall.a
TEST_BIN := $(BUILD_DIR)/kotlin_polycall_adapter_test
KOTLIN_TEST_JAR := $(BUILD_DIR)/kotlin-polycall-test.jar
KOTLIN_SOURCES := src/main/kotlin/org/obinexus/polycall/Polycall.kt

ifeq ($(OS),Windows_NT)
EXE_EXT := .exe
JNI_PLATFORM := win32
JNI_LIB := $(LIB_DIR)/kotlin_polycall.dll
MOCK_JNI_LIB := $(BUILD_DIR)/kotlin_polycall.dll
TEST_BIN := $(TEST_BIN)$(EXE_EXT)
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
JNI_PLATFORM := darwin
JNI_LIB := $(LIB_DIR)/libkotlin_polycall.dylib
MOCK_JNI_LIB := $(BUILD_DIR)/libkotlin_polycall.dylib
else
JNI_PLATFORM := linux
JNI_LIB := $(LIB_DIR)/libkotlin_polycall.so
MOCK_JNI_LIB := $(BUILD_DIR)/libkotlin_polycall.so
endif
endif

.DEFAULT_GOAL := all

.PHONY: all
all: $(STATIC_LIB)

$(BUILD_DIR) $(LIB_DIR):
ifeq ($(OS),Windows_NT)
	@if not exist "$@" mkdir "$@"
else
	@mkdir -p $@
endif

$(ADAPTER_OBJ): c_src/kotlin_polycall.c include/kotlin_polycall.h generated/polycall/polycall_ffi.h | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

$(STATIC_LIB): $(ADAPTER_OBJ) | $(LIB_DIR)
	$(AR) rcs $@ $^

$(TEST_BIN): c_src/kotlin_polycall.c tests/polycall_ffi_mock.c tests/kotlin_polycall_adapter_test.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) -Itests $(CFLAGS) $^ -o $@

.PHONY: test
test: $(TEST_BIN)
	$(TEST_BIN)

.PHONY: jni
jni: | $(LIB_DIR)
ifeq ($(OS),Windows_NT)
	@if "$(strip $(JAVA_HOME))"=="" (echo Set JAVA_HOME to a JDK installation & exit /b 2)
	@if "$(strip $(POLYCALL_LDFLAGS))"=="" (echo Set POLYCALL_LDFLAGS to the libpolycall v1.5 linker flags & exit /b 2)
else
	@test -n "$(JAVA_HOME)" || (echo "Set JAVA_HOME to a JDK installation" && exit 2)
	@test -n "$(POLYCALL_LDFLAGS)" || (echo "Set POLYCALL_LDFLAGS to the libpolycall v1.5 linker flags" && exit 2)
endif
	$(CC) $(CPPFLAGS) -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/$(JNI_PLATFORM)" \
		$(CFLAGS) $(JNI_CFLAGS) -shared c_src/kotlin_polycall.c \
		c_src/kotlin_polycall_jni.c $(POLYCALL_LDFLAGS) -o $(JNI_LIB)

$(MOCK_JNI_LIB): c_src/kotlin_polycall.c c_src/kotlin_polycall_jni.c tests/polycall_ffi_mock.c | $(BUILD_DIR)
ifeq ($(OS),Windows_NT)
	@if "$(strip $(JAVA_HOME))"=="" (echo Set JAVA_HOME to a JDK installation & exit /b 2)
else
	@test -n "$(JAVA_HOME)" || (echo "Set JAVA_HOME to a JDK installation" && exit 2)
endif
	$(CC) $(CPPFLAGS) -Itests -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/$(JNI_PLATFORM)" \
		$(CFLAGS) $(JNI_CFLAGS) -shared c_src/kotlin_polycall.c \
		c_src/kotlin_polycall_jni.c tests/polycall_ffi_mock.c -o $@

.PHONY: kotlin-build
kotlin-build: | $(BUILD_DIR)
	$(KOTLINC) $(KOTLIN_SOURCES) -d $(BUILD_DIR)/kotlin-polycall.jar

.PHONY: gradle-build
gradle-build:
	$(GRADLE) build

.PHONY: test-kotlin
test-kotlin: $(MOCK_JNI_LIB) | $(BUILD_DIR)
	$(KOTLINC) $(KOTLIN_SOURCES) tests/KotlinPolycallSmoke.kt \
		-include-runtime -d $(KOTLIN_TEST_JAR)
	$(JAVA) -Dkotlin.polycall.library="$(abspath $(MOCK_JNI_LIB))" \
		-cp $(KOTLIN_TEST_JAR) org.obinexus.polycall.KotlinPolycallSmokeKt

.PHONY: verify-dry
verify-dry:
ifeq ($(OS),Windows_NT)
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-dry.ps1
else
	sh scripts/verify-dry.sh
endif

.PHONY: clean
clean:
ifeq ($(OS),Windows_NT)
	@if exist "$(BUILD_DIR)" rmdir /s /q "$(BUILD_DIR)"
	@if exist "$(LIB_DIR)" rmdir /s /q "$(LIB_DIR)"
	@if exist ".gradle" rmdir /s /q ".gradle"
else
	rm -rf $(BUILD_DIR) $(LIB_DIR) .gradle
endif

-include $(ADAPTER_OBJ:.o=.d)
