ifneq (3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
  $(error "Requires make version 3.82 or later (current is $(MAKE_VERSION))")
endif

# root directory of tensorflow
TENSORFLOW_ROOT :=
RELATIVE_MAKEFILE_DIR := tensorflow/lite/micro/tools/make
MAKEFILE_DIR := $(TENSORFLOW_ROOT)$(RELATIVE_MAKEFILE_DIR)
DOWNLOADS_DIR := $(MAKEFILE_DIR)/downloads

# Pull in some convenience functions.
include $(MAKEFILE_DIR)/helper_functions.inc

# Try to figure out the host system
HOST_OS :=
ifeq ($(OS),Windows_NT)
	HOST_OS = windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		HOST_OS := linux
	endif
	ifeq ($(UNAME_S),Darwin)
		HOST_OS := osx
	endif
endif

# Determine the host architecture, with any ix86 architecture being labelled x86_32
HOST_ARCH := $(shell if uname -m | grep -Eq 'i[345678]86'; then echo x86_32; else echo $(shell uname -m); fi)

# Override these on the make command line to target a specific architecture. For example:
# make -f tensorflow/lite/Makefile TARGET=rpi TARGET_ARCH=armv7l
TARGET := $(HOST_OS)
TARGET_ARCH := $(HOST_ARCH)

# Default compiler and tool names:
TOOLCHAIN := gcc
CXX_TOOL := g++
CC_TOOL := gcc
AR_TOOL := ar

OPTIMIZED_KERNEL_DIR :=
OPTIMIZED_KERNEL_DIR_PREFIX := $(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels
CO_PROCESSOR :=

# This is the way to specify any code path that we want to Include in the build
# process. This will help us to include external code (code that is not part of
# github repo) be tested.
EXTERNAL_DIR :=

INC := \
-I. \
-I$(DOWNLOADS_DIR) \
-I$(DOWNLOADS_DIR)/gemmlowp \
-I$(DOWNLOADS_DIR)/flatbuffers/include \
-I$(DOWNLOADS_DIR)/kissfft \
-I$(DOWNLOADS_DIR)/ruy
ifneq ($(TENSORFLOW_ROOT),)
  INC += -I$(TENSORFLOW_ROOT)
endif
ifneq ($(EXTERNAL_DIR),)
  INC += -I$(EXTERNAL_DIR)
endif

TEST_SCRIPT :=

ADDITIONAL_DEFINES :=
ifneq ($(OPTIMIZED_KERNEL_DIR),)
  ADDITIONAL_DEFINES += -D$(shell echo $(OPTIMIZED_KERNEL_DIR) | tr [a-z] [A-Z])
endif
ifneq ($(CO_PROCESSOR),)
  ADDITIONAL_DEFINES += -D$(shell echo $(CO_PROCESSOR) | tr [a-z] [A-Z])
endif
ifeq ($(TOOLCHAIN), armclang)
  CORE_OPTIMIZATION_LEVEL := -Oz
else
  CORE_OPTIMIZATION_LEVEL := -Os
endif
KERNEL_OPTIMIZATION_LEVEL := -O2
THIRD_PARTY_KERNEL_OPTIMIZATION_LEVEL := -O2

ADDITIONAL_WARNS := \
  -Wsign-compare \
  -Wdouble-promotion \
  -Wunused-variable \
  -Wunused-function \
  -Wswitch \
  -Wall \
  -Wextra \
  -Wmissing-field-initializers \
  -Wstrict-aliasing \
  -Wno-unused-parameter

CFLAGS += \
  -fno-unwind-tables \
  -ffunction-sections \
  -fdata-sections \
  -fmessage-length=0 \
  -DTF_LITE_STATIC_MEMORY \
  -DTF_LITE_DISABLE_X86_NEON \
  -Wimplicit-function-declaration \
  $(ADDITIONAL_DEFINES) \

ifeq ($(TARGET), $(HOST_OS))
  CFLAGS += -DTF_LITE_USE_CTIME
endif

CXXFLAGS += \
  -fno-rtti \
  -fno-exceptions \
  -fno-threadsafe-statics \
  -Wnon-virtual-dtor \
  -fpermissive \

ARFLAGS := -r

ifeq ($(TOOLCHAIN), gcc)
  ifneq ($(TARGET), osx)
    LDFLAGS += \
      -Wl,--fatal-warnings \
      -Wl,--gc-sections
  endif
endif

TARGET_TOOLCHAIN_PREFIX :=
TARGET_TOOLCHAIN_ROOT :=

BUILD_TYPE := default
MICROLITE_LIB_NAME := libtensorflow-microlite.a

# Where compiled objects are stored.
BASE_GENDIR := gen
GENDIR := $(BASE_GENDIR)/$(TARGET)_$(TARGET_ARCH)_$(BUILD_TYPE)/
CORE_OBJDIR := $(GENDIR)obj/core/
KERNEL_OBJDIR := $(GENDIR)obj/kernels/
THIRD_PARTY_KERNEL_OBJDIR := $(GENDIR)obj/third_party_kernels/
THIRD_PARTY_OBJDIR := $(GENDIR)obj/third_party/
GENERATED_SRCS_DIR := $(GENDIR)genfiles/
BINDIR := $(GENDIR)bin/
LIBDIR := $(GENDIR)lib/
PRJDIR := $(GENDIR)prj/

# Include tests and benchmarks
MICRO_LITE_EXAMPLE_TESTS := $(shell find $(TENSORFLOW_ROOT)tensorflow/lite/micro/examples/ -maxdepth 2 -name Makefile.inc)
ifneq ($(EXTERNAL_DIR),)
  MICRO_LITE_EXAMPLE_TESTS += $(shell find $(EXTERNAL_DIR) -name Makefile_internal.inc)
endif
MICRO_LITE_INTEGRATION_TESTS += $(shell find $(TENSORFLOW_ROOT)tensorflow/lite/micro/integration_tests -name Makefile.inc)
MICRO_LITE_GEN_MUTABLE_OP_RESOLVER_TEST += $(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/tools/gen_micro_mutable_op_resolver_test/person_detect/Makefile.inc)
MICRO_LITE_BENCHMARKS := $(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/tools/benchmarking/Makefile.inc)
MICROLITE_BENCHMARK_SRCS := $(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/tools/benchmarking/*benchmark.cc)

MICROLITE_TEST_SRCS := \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/fake_micro_context_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/flatbuffer_utils_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_arena_threshold_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_helpers_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_allocation_info_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_context_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_log_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_interpreter_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_mutable_op_resolver_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_resource_variable_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_time_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_utils_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/recording_micro_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/non_persistent_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/persistent_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/recording_single_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/single_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/testing_helpers_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/greedy_memory_planner_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/linear_memory_planner_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/non_persistent_buffer_planner_shim_test.cc

MICROLITE_CC_KERNEL_SRCS := \
$(TENSORFLOW_ROOT)signal/micro/kernels/delay.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/energy.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/fft_auto_scale.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/filter_bank.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/filter_bank_log.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/filter_bank_square_root.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/filter_bank_spectral_subtraction.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/framer.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/irfft.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/rfft.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/stacker.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/overlap_add.cc \
$(TENSORFLOW_ROOT)signal/micro/kernels/window.cc \
$(TENSORFLOW_ROOT)signal/src/circular_buffer.cc \
$(TENSORFLOW_ROOT)signal/src/energy.cc \
$(TENSORFLOW_ROOT)signal/src/fft_auto_scale.cc \
$(TENSORFLOW_ROOT)signal/src/filter_bank.cc \
$(TENSORFLOW_ROOT)signal/src/filter_bank_log.cc \
$(TENSORFLOW_ROOT)signal/src/filter_bank_square_root.cc \
$(TENSORFLOW_ROOT)signal/src/filter_bank_spectral_subtraction.cc \
$(TENSORFLOW_ROOT)signal/src/irfft_float.cc \
$(TENSORFLOW_ROOT)signal/src/irfft_int16.cc \
$(TENSORFLOW_ROOT)signal/src/irfft_int32.cc \
$(TENSORFLOW_ROOT)signal/src/log.cc \
$(TENSORFLOW_ROOT)signal/src/max_abs.cc \
$(TENSORFLOW_ROOT)signal/src/msb_32.cc \
$(TENSORFLOW_ROOT)signal/src/msb_64.cc \
$(TENSORFLOW_ROOT)signal/src/overlap_add.cc \
$(TENSORFLOW_ROOT)signal/src/rfft_float.cc \
$(TENSORFLOW_ROOT)signal/src/rfft_int16.cc \
$(TENSORFLOW_ROOT)signal/src/rfft_int32.cc \
$(TENSORFLOW_ROOT)signal/src/square_root_32.cc \
$(TENSORFLOW_ROOT)signal/src/square_root_64.cc \
$(TENSORFLOW_ROOT)signal/src/window.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/activations.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/activations_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/add.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/add_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/add_n.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/arg_min_max.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/assign_variable.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/batch_to_space_nd.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/broadcast_args.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/broadcast_to.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/call_once.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/cast.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/ceil.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/circular_buffer.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/circular_buffer_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/comparisons.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/concatenation.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/conv.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/conv_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/cumsum.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/depth_to_space.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/depthwise_conv.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/depthwise_conv_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/dequantize.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/dequantize_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/detection_postprocess.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/div.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/elementwise.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/elu.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/embedding_lookup.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/ethosu.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/exp.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/expand_dims.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/fill.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/floor.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/floor_div.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/floor_mod.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/fully_connected.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/fully_connected_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/gather.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/gather_nd.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/hard_swish.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/hard_swish_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/if.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/kernel_runner.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/kernel_util.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/l2norm.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/l2_pool_2d.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/leaky_relu.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/leaky_relu_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/logical.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/logical_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/logistic.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/logistic_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/log_softmax.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/lstm_eval.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/lstm_eval_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/maximum_minimum.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/micro_tensor_utils.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/mirror_pad.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/mul.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/mul_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/neg.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/pack.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/pad.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/pooling.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/pooling_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/prelu.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/prelu_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/quantize.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/quantize_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/read_variable.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/reduce.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/reduce_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/reshape.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/reshape_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/resize_bilinear.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/resize_nearest_neighbor.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/round.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/select.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/shape.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/slice.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/softmax.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/softmax_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/space_to_batch_nd.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/space_to_depth.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/split.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/split_v.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/squared_difference.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/squeeze.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/strided_slice.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/sub.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/sub_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/svdf.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/svdf_common.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/tanh.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/transpose.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/transpose_conv.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/unidirectional_sequence_lstm.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/unpack.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/var_handle.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/while.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/zeros_like.cc

MICROLITE_TEST_HDRS := $(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/testing/*.h)
TFL_CC_SRCS := $(shell find $(TENSORFLOW_ROOT)tensorflow/lite -type d \( -path $(TENSORFLOW_ROOT)tensorflow/lite/experimental -o -path $(TENSORFLOW_ROOT)tensorflow/lite/micro \) -prune -false -o -name "*.cc" -o -name "*.c")
TFL_CC_HDRS := $(shell find $(TENSORFLOW_ROOT)tensorflow/lite -type d \( -path $(TENSORFLOW_ROOT)tensorflow/lite/experimental -o -path $(TENSORFLOW_ROOT)tensorflow/lite/micro \) -prune -false -o -name "*.h")

ifneq ($(BUILD_TYPE), no_tf_lite_static_memory)
  EXCLUDED_TFL_CC_SRCS := \
  	$(TENSORFLOW_ROOT)tensorflow/lite/array.cc
  TFL_CC_SRCS := $(filter-out $(EXCLUDED_TFL_CC_SRCS), $(TFL_CC_SRCS))
  EXCLUDED_TFL_CC_HDRS := \
  	$(TENSORFLOW_ROOT)tensorflow/lite/array.h
  TFL_CC_HDRS := $(filter-out $(EXCLUDED_TFL_CC_HDRS), $(TFL_CC_HDRS))
endif

MICROLITE_CC_BASE_SRCS := \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/*.cc) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/*.cc) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/*.cc) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/tflite_bridge/*.cc) \
$(TFL_CC_SRCS)

MICROLITE_CC_HDRS := \
$(wildcard $(TENSORFLOW_ROOT)signal/micro/kernels/*.h) \
$(wildcard $(TENSORFLOW_ROOT)signal/src/*.h) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/*.h) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/benchmarks/*model_data.h) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/*.h) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/*.h) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/*.h) \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/tflite_bridge/*.h) \
$(TENSORFLOW_ROOT)LICENSE \
$(TFL_CC_HDRS)

THIRD_PARTY_CC_HDRS := \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/allocator.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/array.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/base.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/buffer.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/buffer_ref.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/default_allocator.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/detached_buffer.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/flatbuffer_builder.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/flatbuffers.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/flexbuffers.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/stl_emulation.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/string.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/struct.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/table.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/vector.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/vector_downward.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/verifier.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/util.h \
$(DOWNLOADS_DIR)/flatbuffers/LICENSE.txt \
$(DOWNLOADS_DIR)/gemmlowp/fixedpoint/fixedpoint.h \
$(DOWNLOADS_DIR)/gemmlowp/fixedpoint/fixedpoint_neon.h \
$(DOWNLOADS_DIR)/gemmlowp/fixedpoint/fixedpoint_sse.h \
$(DOWNLOADS_DIR)/gemmlowp/internal/detect_platform.h \
$(DOWNLOADS_DIR)/gemmlowp/LICENSE \
$(DOWNLOADS_DIR)/kissfft/COPYING \
$(DOWNLOADS_DIR)/kissfft/kiss_fft.c \
$(DOWNLOADS_DIR)/kissfft/kiss_fft.h \
$(DOWNLOADS_DIR)/kissfft/_kiss_fft_guts.h \
$(DOWNLOADS_DIR)/kissfft/tools/kiss_fftr.c \
$(DOWNLOADS_DIR)/kissfft/tools/kiss_fftr.h \
$(DOWNLOADS_DIR)/ruy/ruy/profiler/instrumentation.h

THIRD_PARTY_CC_SRCS :=
THIRD_PARTY_KERNEL_CC_SRCS :=

# Load custom kernels
include $(MAKEFILE_DIR)/additional_kernels.inc

MICROLITE_CC_SRCS := $(filter-out $(MICROLITE_TEST_SRCS), $(MICROLITE_CC_BASE_SRCS))
MICROLITE_CC_SRCS := $(filter-out $(MICROLITE_BENCHMARK_SRCS), $(MICROLITE_CC_SRCS))

# Handle third party dependency downloads
$(shell mkdir -p ${DOWNLOADS_DIR})
DOWNLOAD_RESULT := $(shell $(MAKEFILE_DIR)/flatbuffers_download.sh ${DOWNLOADS_DIR} $(TENSORFLOW_ROOT))
ifneq ($(DOWNLOAD_RESULT), SUCCESS)
  $(error Something went wrong with the flatbuffers download: $(DOWNLOAD_RESULT))
endif
DOWNLOAD_RESULT := $(shell $(MAKEFILE_DIR)/kissfft_download.sh ${DOWNLOADS_DIR} $(TENSORFLOW_ROOT))
ifneq ($(DOWNLOAD_RESULT), SUCCESS)
  $(error Something went wrong with the kissfft download: $(DOWNLOAD_RESULT))
endif
DOWNLOAD_RESULT := $(shell $(MAKEFILE_DIR)/pigweed_download.sh ${DOWNLOADS_DIR} $(TENSORFLOW_ROOT))
ifneq ($(DOWNLOAD_RESULT), SUCCESS)
  $(error Something went wrong with the pigweed download: $(DOWNLOAD_RESULT))
endif
include $(MAKEFILE_DIR)/third_party_downloads.inc
THIRD_PARTY_DOWNLOADS :=
$(eval $(call add_third_party_download,$(GEMMLOWP_URL),$(GEMMLOWP_MD5),gemmlowp,))
$(eval $(call add_third_party_download,$(RUY_URL),$(RUY_MD5),ruy,))

TARGETS_WITHOUT_MAKEFILES := $(HOST_OS)
TARGET_SPECIFIC_MAKE_TEST:=0
ifeq ($(findstring $(TARGET),$(TARGETS_WITHOUT_MAKEFILES)),)
  include $(MAKEFILE_DIR)/targets/$(TARGET)_makefile.inc
endif


ifneq ($(OPTIMIZED_KERNEL_DIR),)
  PATH_TO_OPTIMIZED_KERNELS := $(OPTIMIZED_KERNEL_DIR_PREFIX)/$(OPTIMIZED_KERNEL_DIR)
  RESULT := $(shell $(MAKEFILE_DIR)/check_optimized_kernel_dir.sh $(PATH_TO_OPTIMIZED_KERNELS))
  ifneq ($(RESULT), SUCCESS)
    $(error Incorrect OPTIMIZED_KERNEL_DIR: $(RESULT))
  endif
  include $(MAKEFILE_DIR)/ext_libs/$(OPTIMIZED_KERNEL_DIR).inc
  MICROLITE_CC_KERNEL_SRCS := $(shell python3 $(MAKEFILE_DIR)/specialize_files.py \
		--base_files "$(MICROLITE_CC_KERNEL_SRCS)" \
		--specialize_directory $(PATH_TO_OPTIMIZED_KERNELS))
  ifneq ($(.SHELLSTATUS),)
    ifneq ($(.SHELLSTATUS),0)
      $(error Error with specialize_files.py $(MICROLITE_CC_KERNEL_SRCS))
    endif
  endif
  MICROLITE_CC_HDRS += $(wildcard $(PATH_TO_OPTIMIZED_KERNELS)/*.h)
endif

ifneq ($(CO_PROCESSOR),)
  include $(MAKEFILE_DIR)/ext_libs/$(CO_PROCESSOR).inc
  PATH_TO_COPROCESSOR_KERNELS := $(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/$(CO_PROCESSOR)
  MICROLITE_CC_KERNEL_SRCS := $(shell python3 $(MAKEFILE_DIR)/specialize_files.py \
    --base_files "$(MICROLITE_CC_KERNEL_SRCS)" \
    --specialize_directory $(PATH_TO_COPROCESSOR_KERNELS))
  ifneq ($(.SHELLSTATUS),)
    ifneq ($(.SHELLSTATUS),0)
      $(error Error with specialize_files.py $(MICROLITE_CC_KERNEL_SRCS))
    endif
  endif
endif

PATH_TO_TARGET_SRCS := $(TENSORFLOW_ROOT)tensorflow/lite/micro/$(TARGET)
MICROLITE_CC_SRCS := $(shell python3 $(MAKEFILE_DIR)/specialize_files.py \
  --base_files "$(MICROLITE_CC_SRCS)" \
  --specialize_directory $(PATH_TO_TARGET_SRCS))
ifneq ($(.SHELLSTATUS),)
  ifneq ($(.SHELLSTATUS),0)
    $(error Error with specialize_files.py $(MICROLITE_CC_SRCS))
  endif
endif

ALL_SRCS := $(MICROLITE_CC_SRCS) $(MICROLITE_CC_KERNEL_SRCS)
MICROLITE_LIB_PATH := $(LIBDIR)$(MICROLITE_LIB_NAME)
AR := $(TARGET_TOOLCHAIN_ROOT)${TARGET_TOOLCHAIN_PREFIX}${AR_TOOL}

MICROSPEECH_ROOT := $(TENSORFLOW_ROOT)tensorflow/lite/micro/examples/micro_speech

SRC_CXX += $(MICROLITE_CC_SRCS) $(MICROLITE_CC_KERNEL_SRCS)
SRC_CXX += $(shell find $(TENSORFLOW_ROOT)$(MICROSPEECH_ROOT)/micro_features -type f -name "*.cc")
SRC_CXX += $(shell find $(TENSORFLOW_ROOT)gen -type f -name "*.cc")

SRC_QSTR += $(SRC_C) $(SRC_CXX)

OBJ += $(PY_O)
OBJ += $(addprefix build/, $(SRC_C:.c=.o))
OBJ += $(addprefix build/, $(SRC_CXX:.cc=.o))

# Include the core environment definitions
include micropython/py/mkenv.mk

# Set makefile-level MicroPython feature configurations
MICROPY_ROM_TEXT_COMPRESSION ?= 1

# Which python files to freeze into the firmware are listed in here
FROZEN_MANIFEST = modules/frozen-manifest.py

# Include py core make definitions
include micropython/py/py.mk
include micropython/extmod/extmod.mk

# Define the toolchain prefix for ARM GCC
CROSS_COMPILE = arm-none-eabi-

# Use date and time as build version "vYY.DDD.HHMM". := forces evaluation once
BUILD_VERSION := $(shell TZ= date +v%y.%j.%H%M)

# Warning options
WARN := -Wall

# Build optimizations
OPT += -mcpu=cortex-m4
OPT += -mthumb
OPT += -mabi=aapcs
OPT += -mfloat-abi=hard
OPT += -mfpu=fpv4-sp-d16
OPT += -std=gnu17
OPT += -Os -g0
OPT += -fdata-sections -ffunction-sections 
OPT += -fshort-enums
OPT += -fno-strict-aliasing
OPT += -fno-common
OPT += -flto

# Save some code space for performance-critical code
CSUPEROPT = -Os

# Set defines
DEFS += -DNRF52832_XXAA
DEFS += -DNDEBUG
DEFS += -DCONFIG_NFCT_PINS_AS_GPIOS
DEFS += -DBUILD_VERSION='"$(BUILD_VERSION)"'
DEFS += -DLFS2_NO_ASSERT

# Set linker options
LDFLAGS += -Lnrfx/mdk -T monocle-nrf52dk/monocle.ld
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Xlinker -Map=$(@:.elf=.map)
LDFLAGS += --specs=nano.specs
LDFLAGS += --specs=nosys.specs

INC += -I.
INC += -Ibuild
INC += -Imicropython
INC += -Imicropython/lib/cmsis/inc
INC += -Imicropython/shared/readline
INC += -Imodules
INC += -Imodules/libvgrs/src
INC += -Imonocle-nrf52dk
INC += -Inrfx
INC += -Inrfx/drivers
INC += -Inrfx/drivers/include
INC += -Inrfx/drivers/src
INC += -Inrfx/hal
INC += -Inrfx/helpers
INC += -Inrfx/mdk
INC += -Inrfx/soc
INC += -Isegger
INC += -Isoftdevice/include
INC += -Isoftdevice/include/nrf52

INC += \
-I$(DOWNLOADS_DIR) \
-I$(DOWNLOADS_DIR)/gemmlowp \
-I$(DOWNLOADS_DIR)/flatbuffers/include \
-I$(DOWNLOADS_DIR)/kissfft \
-I$(DOWNLOADS_DIR)/ruy

SRC_C += main.c
SRC_C += monocle-nrf52dk/monocle-critical.c
SRC_C += monocle-nrf52dk/monocle-drivers.c
SRC_C += monocle-nrf52dk/monocle-startup.c
SRC_C += mphalport.c

SRC_C += modules/bluetooth.c
SRC_C += modules/camera.c
SRC_C += modules/device.c
SRC_C += modules/display.c
SRC_C += modules/fpga.c
SRC_C += modules/led.c
SRC_C += modules/microphone.c
SRC_C += modules/rtt.c
SRC_C += modules/storage.c
SRC_C += modules/touch.c
SRC_C += modules/update.c
SRC_C += modules/libvgrs/src/modvgr2d.c
SRC_C += modules/libvgrs/src/vgr2dlib.c
SRC_C += modules/modvgr2d-glue.c

SRC_C += segger/SEGGER_RTT_printf.c
SRC_C += segger/SEGGER_RTT_Syscalls_GCC.c
SRC_C += segger/SEGGER_RTT.c

SRC_C += micropython/shared/readline/readline.c
SRC_C += micropython/shared/runtime/gchelper_generic.c
SRC_C += micropython/shared/runtime/interrupt_char.c
SRC_C += micropython/shared/runtime/pyexec.c
SRC_C += micropython/shared/runtime/stdout_helpers.c
SRC_C += micropython/shared/runtime/sys_stdio_mphal.c
SRC_C += micropython/shared/timeutils/timeutils.c

SRC_C += micropython/lib/libm/acoshf.c
SRC_C += micropython/lib/libm/asinfacosf.c
SRC_C += micropython/lib/libm/asinhf.c
SRC_C += micropython/lib/libm/atan2f.c
SRC_C += micropython/lib/libm/atanf.c
SRC_C += micropython/lib/libm/atanhf.c
SRC_C += micropython/lib/libm/ef_rem_pio2.c
SRC_C += micropython/lib/libm/ef_sqrt.c
SRC_C += micropython/lib/libm/erf_lgamma.c
SRC_C += micropython/lib/libm/fmodf.c
SRC_C += micropython/lib/libm/kf_cos.c
SRC_C += micropython/lib/libm/kf_rem_pio2.c
SRC_C += micropython/lib/libm/kf_sin.c
SRC_C += micropython/lib/libm/kf_tan.c
SRC_C += micropython/lib/libm/log1pf.c
SRC_C += micropython/lib/libm/math.c
SRC_C += micropython/lib/libm/nearbyintf.c
SRC_C += micropython/lib/libm/roundf.c
SRC_C += micropython/lib/libm/sf_cos.c
SRC_C += micropython/lib/libm/sf_erf.c
SRC_C += micropython/lib/libm/sf_frexp.c
SRC_C += micropython/lib/libm/sf_ldexp.c
SRC_C += micropython/lib/libm/sf_modf.c
SRC_C += micropython/lib/libm/sf_sin.c
SRC_C += micropython/lib/libm/sf_tan.c
SRC_C += micropython/lib/libm/wf_lgamma.c
SRC_C += micropython/lib/libm/wf_tgamma.c
SRC_C += micropython/lib/littlefs/lfs2_util.c
SRC_C += micropython/lib/littlefs/lfs2.c
SRC_C += micropython/lib/uzlib/crc32.c

SRC_C += nrfx/drivers/src/nrfx_clock.c
SRC_C += nrfx/drivers/src/nrfx_gpiote.c
SRC_C += nrfx/drivers/src/nrfx_nvmc.c
SRC_C += nrfx/drivers/src/nrfx_rtc.c
SRC_C += nrfx/drivers/src/nrfx_saadc.c
SRC_C += nrfx/drivers/src/nrfx_spi.c
SRC_C += nrfx/drivers/src/nrfx_spim.c
SRC_C += nrfx/drivers/src/nrfx_systick.c
SRC_C += nrfx/drivers/src/nrfx_timer.c
SRC_C += nrfx/drivers/src/nrfx_twim.c
SRC_C += nrfx/drivers/src/prs/nrfx_prs.c
SRC_C += nrfx/helpers/nrfx_flag32_allocator.c
SRC_C += nrfx/mdk/system_nrf52.c

SRC_C += modules/experimental.c
SRC_C += modules/kws.c
# SRC_C += modules/c_microphone.c

SRC_CXX += modules/helpers/experimental_helper.cc
SRC_CXX += modules/helpers/kws_helper.cc

# Link required libraries
LIB += -lm -lc -lnosys -lgcc -lstdc++

INC += -I$(GENERATED_SRCS_DIR)
INC += -I$(GENERATED_SRCS_DIR)$(TENSORFLOW_ROOT)

# Assemble the C flags variable
CFLAGS += $(WARN) $(OPT) $(INC) $(DEFS)
CXXFLAGS += $(filter-out -std=gnu17 -Wimplicit-function-declaration,$(CFLAGS))

include $(MICRO_LITE_EXAMPLE_TESTS)
include $(MICRO_LITE_INTEGRATION_TESTS)
include ${MICRO_LITE_GEN_MUTABLE_OP_RESOLVER_TEST}
include $(MICRO_LITE_BENCHMARKS)
include $(MAKEFILE_DIR)/additional_tests.inc

THIRD_PARTY_TARGETS :=
$(foreach DOWNLOAD,$(THIRD_PARTY_DOWNLOADS),$(eval $(call create_download_rule,$(DOWNLOAD))))
third_party_downloads: $(THIRD_PARTY_TARGETS)

MICROLITE_LIB_OBJS := $(addprefix $(CORE_OBJDIR), \
$(patsubst %.S,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(MICROLITE_CC_SRCS)))))

MICROLITE_THIRD_PARTY_OBJS := $(addprefix $(THIRD_PARTY_OBJDIR), \
$(patsubst %.S,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(THIRD_PARTY_CC_SRCS)))))

MICROLITE_THIRD_PARTY_KERNEL_OBJS := $(addprefix $(THIRD_PARTY_KERNEL_OBJDIR), \
$(patsubst %.S,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(THIRD_PARTY_KERNEL_CC_SRCS)))))

MICROLITE_KERNEL_OBJS := $(addprefix $(KERNEL_OBJDIR), \
$(patsubst %.S,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(MICROLITE_CC_KERNEL_SRCS)))))

all: build/application.hex
gen: $(MICROLITE_LIB_PATH) $(MICROLITE_BUILD_TARGETS)

$(CORE_OBJDIR)%.o: %.cc $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CORE_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(CORE_OBJDIR)%.o: %.c $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CORE_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(CORE_OBJDIR)%.o: %.S $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CORE_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(THIRD_PARTY_OBJDIR)%.o: %.cc $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CORE_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(THIRD_PARTY_OBJDIR)%.o: %.c $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CORE_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(THIRD_PARTY_OBJDIR)%.o: %.S $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CORE_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(THIRD_PARTY_KERNEL_OBJDIR)%.o: %.cc $(THIRD_PARTY_KERNEL_TARGETS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(THIRD_PARTY_KERNEL_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(THIRD_PARTY_KERNEL_OBJDIR)%.o: %.c $(THIRD_PARTY_KERNEL_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(THIRD_PARTY_KERNEL_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(THIRD_PARTY_KERNEL_OBJDIR)%.o: %.S $(THIRD_PARTY_KERNEL_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(THIRD_PARTY_KERNEL_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(KERNEL_OBJDIR)%.o: %.cc $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(KERNEL_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(KERNEL_OBJDIR)%.o: %.c $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(KERNEL_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

$(KERNEL_OBJDIR)%.o: %.S $(THIRD_PARTY_TARGETS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(KERNEL_OPTIMIZATION_LEVEL) $(INC) -c $< -o $@

microlite: $(MICROLITE_LIB_PATH)

# Gathers together all the objects we've compiled into a single '.a' archive.
$(MICROLITE_LIB_PATH): $(MICROLITE_LIB_OBJS) $(MICROLITE_KERNEL_OBJS) $(MICROLITE_THIRD_PARTY_OBJS) $(MICROLITE_THIRD_PARTY_KERNEL_OBJS) $(MICROLITE_CUSTOM_OP_OBJS)
	@mkdir -p $(dir $@)
	$(AR) $(ARFLAGS) $(MICROLITE_LIB_PATH) $(MICROLITE_LIB_OBJS) \
	$(MICROLITE_KERNEL_OBJS) $(MICROLITE_THIRD_PARTY_OBJS) $(MICROLITE_THIRD_PARTY_KERNEL_OBJS) $(MICROLITE_CUSTOM_OP_OBJS)

$(BINDIR)%_test : $(CORE_OBJDIR)%_test.o $(MICROLITE_LIB_PATH)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INC) \
	-o $@ $< \
	$(MICROLITE_LIB_PATH) $(LDFLAGS) $(LIB)

$(BINDIR)%.test_target: $(BINDIR)%_test
	@test -f $(TEST_SCRIPT) || (echo 'Unable to find the test script. Is the software emulation available in $(TARGET)?'; exit 1)
	$(TEST_SCRIPT) $<

ifeq ($(TOOLCHAIN), armclang)
  FROMELF := ${TARGET_TOOLCHAIN_ROOT}$(TARGET_TOOLCHAIN_PREFIX)fromelf
  $(BINDIR)%.bin: $(BINDIR)%
		@mkdir -p $(dir $@)
		$(FROMELF) --bin --output=$@ $<
else
  $(BINDIR)%.bin: $(BINDIR)%
		@mkdir -p $(dir $@)
		$(OBJCOPY) $< $@ -O binary
endif

include $(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/Makefile.inc
include $(TENSORFLOW_ROOT)tensorflow/lite/micro/tools/ci_build/binary_size_test/Makefile.inc
$(foreach TEST_TARGET,$(filter-out $(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/%,$(MICROLITE_TEST_SRCS)),\
$(eval $(call microlite_test,$(notdir $(basename $(TEST_TARGET))),$(TEST_TARGET))))

ifeq ($(TARGET_SPECIFIC_MAKE_TEST),0)
test: $(MICROLITE_TEST_TARGETS)
integration_tests: $(MICROLITE_INTEGRATION_TEST_TARGETS)
generated_micro_mutable_op_resolver: $(MICROLITE_GEN_OP_RESOLVER_TEST_TARGETS)
endif

build/application.hex: build/application.elf
	$(OBJCOPY) -O ihex $< $@

build/application.elf: $(OBJ)
	$(ECHO) "Generated TFLM *.o:"
	$(ECHO) $(OBJ)
	$(Q)$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LIB)
	$(Q)$(SIZE) $@

flash: build/application.hex
	nrfjprog --program softdevice/*.hex --chiperase -f nrf52 --verify
	nrfjprog --program $< -f nrf52 --verify
	nrfjprog --reset -f nrf52

release: build/application.hex
	nrfutil settings generate --family NRF52 --application build/application.hex --application-version 0 --bootloader-version 0 --bl-settings-version 2 build/settings.hex
	mergehex -m build/settings.hex build/application.hex softdevice/s132_nrf52_7.3.0_softdevice.hex bootloader/build/nrf52832_xxaa_s132.hex -o build/monocle-micropython-$(BUILD_VERSION).hex
	nrfutil pkg generate --hw-version 52 --application-version 0 --application build/application.hex --sd-req 0x0124 --key-file bootloader/published_privkey.pem build/monocle-micropython-$(BUILD_VERSION).zip

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d
.PRECIOUS: $(BINDIR)%_test

-include $(patsubst %,$(DEPDIR)/%.d,$(basename $(ALL_SRCS)))
include micropython/py/mkrules.mk
