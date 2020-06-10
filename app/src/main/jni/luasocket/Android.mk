LOCAL_PATH := $(call my-dir)

# Tweaks to reuse original luasocket makefile
O=o
SOCKET=usocket.o

# This is from ./luasocket/src/makefile

# DEBUG: NODEBUG DEBUG
# debug mode causes luasocket to collect and returns timing information useful
# for testing and debugging luasocket itself
DEBUG?=NODEBUG

#------
# Compiler and linker settings
# for Linux
DEF_linux=-DLUASOCKET_$(DEBUG)

#------
# Modules belonging to socket-core
#
SOCKET_OBJS= \
	luasocket.$(O) \
	timeout.$(O) \
	buffer.$(O) \
	io.$(O) \
	auxiliar.$(O) \
	compat.$(O) \
	options.$(O) \
	inet.$(O) \
	$(SOCKET) \
	except.$(O) \
	select.$(O) \
	tcp.$(O) \
	udp.$(O)

#------
# Modules belonging mime-core
#
MIME_OBJS= \
	mime.$(O) \
	compat.$(O)
# skipping Unix sockets and Serial modules

# socket-core
include $(CLEAR_VARS)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../lua
LOCAL_C_INCLUDES += $(LOCAL_PATH)/luasocket/src
LOCAL_CFLAGS += $(DEF_linux)
LOCAL_MODULE     := socket_core
LOCAL_SRC_FILES  := $(SOCKET_OBJS:%o=luasocket/src/%c)
LOCAL_SHARED_LIBRARIES := luajava
# LOCAL_ALLOW_UNDEFINED_SYMBOLS = true
# LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog
include $(BUILD_SHARED_LIBRARY)

# mime-core
include $(CLEAR_VARS)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../lua
LOCAL_C_INCLUDES += $(LOCAL_PATH)/luasocket/src
LOCAL_CFLAGS += $(DEF_linux)
LOCAL_MODULE     := mime_core
LOCAL_SRC_FILES  := $(MIME_OBJS:%o=luasocket/src/%c)
LOCAL_SHARED_LIBRARIES := luajava
# LOCAL_ALLOW_UNDEFINED_SYMBOLS = true
# LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog
include $(BUILD_SHARED_LIBRARY)

