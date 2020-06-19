LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../../../app/src/main/jni/lua/lua
LOCAL_C_INCLUDES += $(LOCAL_PATH)/c
LOCAL_MODULE     := luajava
LOCAL_SRC_FILES  := c/luajava.c
LOCAL_STATIC_LIBRARIES := liblua
# LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog

include $(BUILD_SHARED_LIBRARY)
