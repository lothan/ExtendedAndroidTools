BPFTOOL_ANDROID_DEPS = libbpf elfutils
$(eval $(call project-define,bpftool))

BPFTOOL_EXTRA_CFLAGS += "-D__user="
BPFTOOL_EXTRA_CFLAGS += "-D__force="
BPFTOOL_EXTRA_CFLAGS += "-D__poll_t=unsigned"
BPFTOOL_EXTRA_CFLAGS += "-Wno-tautological-constant-out-of-range-compare"
BPFTOOL_EXTRA_CFLAGS += "-Wno-int-conversion"
BPFTOOL_EXTRA_CFLAGS += "-Wno-incompatible-function-pointer-types"
BPFTOOL_EXTRA_CFLAGS += "-I$(abspath $(ANDROID_OUT_DIR)/include)"
BPFTOOL_EXTRA_CFLAGS += "-DFTW_SKIP_SUBTREE=2"
BPFTOOL_EXTRA_CFLAGS += "-DFTW_ACTIONRETVAL=16"

BPFTOOL_EXTRA_LDFLAGS += "-L$(abspath $(ANDROID_OUT_DIR)/lib)"
BPFTOOL_EXTRA_LDFLAGS += "-lz"

$(BPFTOOL_ANDROID): \
    export PKG_CONFIG_LIBDIR=$(abspath $(ANDROID_OUT_DIR)/lib/pkgconfig)
$(BPFTOOL_ANDROID): $(ANDROID_OUT_DIR)/lib/pkgconfig/zlib.pc
	cd $(BPFTOOL_SRCS) && find include/linux -name "*.h" -exec sed -i 's/#error.*compiler-gcc.*directly.*/#pragma message "Warning: compiler-gcc.h included directly"/' {} \;
	cd $(BPFTOOL_SRCS)/src && make install \
		-j $(THREADS) \
		PREFIX=$(abspath $(ANDROID_OUT_DIR)) \
		DESTDIR= \
		OUTPUT=$(abspath $(BPFTOOL_ANDROID_BUILD_DIR))/ \
		AR=$(abspath $(ANDROID_TOOLCHAIN_PATH)/llvm-ar) \
		CC=$(abspath $(ANDROID_TOOLCHAIN_PATH)/$(ANDROID_TRIPLE)$(NDK_API)-clang) \
		HOSTCC=$(abspath $(ANDROID_TOOLCHAIN_PATH)/$(ANDROID_TRIPLE)$(NDK_API)-clang) \
		HOSTLD=$(abspath $(ANDROID_TOOLCHAIN_PATH)/$(ANDROID_TRIPLE)$(NDK_API)-ld) \
		HOSTAR=$(abspath $(ANDROID_TOOLCHAIN_PATH)/llvm-ar) \
		EXTRA_CFLAGS="$(BPFTOOL_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(BPFTOOL_EXTRA_LDFLAGS)" \
		LIBBPF_DIR=$(abspath $(ANDROID_OUT_DIR)) \
		BPF_DIR=$(abspath $(call project-sources,libbpf))/src \
		feature-zlib=1
	cp $(BPFTOOL_SRCS)/LICENSE $(ANDROID_OUT_DIR)/licenses/bpftool
	touch $@

$(BPFTOOL_ANDROID_BUILD_DIR):
	mkdir -p $@

BPFTOOL_TAG = android13-release
BPFTOOL_REPO = https://android.googlesource.com/platform/external/bpftool
projects/bpftool/sources:
	git clone $(BPFTOOL_REPO) $@ -b $(BPFTOOL_TAG)
