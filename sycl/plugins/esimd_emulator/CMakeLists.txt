

# PI Esimd CPU  library
# Create Shared library for libpi_esimd_emulator.so.

include(ExternalProject)

include_directories("${sycl_inc_dir}")
# FIXME/TODO: 'pi.h' is included in 'pi_esimd_emulator.cpp', and CL_*_INTEL
# and CL_*_KHR definitions in 'pi.h' are from
# ${OPENCL_INCLUDE}. Remove build dependency on OpenCL
include_directories(${OpenCL_INCLUDE_DIR})

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_build)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install)

if (MSVC)
  set(LIBCM ${LLVM_BINARY_DIR}/pi_esimd_emulator_deps/lib/libcm${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(LIBIGFXCMRT_EMU ${LLVM_BINARY_DIR}/pi_esimd_emulator_deps/lib/igfxcmrt64_emu${CMAKE_STATIC_LIBRARY_SUFFIX})
else()
  set(LIBCM ${LLVM_BINARY_DIR}/pi_esimd_emulator_deps/lib/libcm${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(LIBIGFXCMRT_EMU ${LLVM_BINARY_DIR}/pi_esimd_emulator_deps/lib/libigfxcmrt_emu${CMAKE_SHARED_LIBRARY_SUFFIX})
endif()

if (DEFINED CM_LOCAL_SOURCE_DIR)
    # Using local CM directory for online building without downloading
  if (MSVC)
    ExternalProject_Add(cm-emu
      DOWNLOAD_COMMAND  ""
      SOURCE_DIR        ${CM_LOCAL_SOURCE_DIR}
      BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_build
      INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install
      CMAKE_ARGS        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      BUILD_BYPRODUCTS  ${LIBCM} ${LIBIGFXCMRT_EMU}
    )
  else()
    ExternalProject_Add(cm-emu
      DOWNLOAD_COMMAND  ""
      SOURCE_DIR        ${CM_LOCAL_SOURCE_DIR}
      BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_build
      INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install
      CMAKE_ARGS        -DLIBVA_INSTALL_PATH=/usr
                        -D__SYCL_EXPLICIT_SIMD_PLUGIN__=true
                        -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      BUILD_BYPRODUCTS  ${LIBCM} ${LIBIGFXCMRT_EMU}
    )
  endif()
else ()
  if (DEFINED CM_PACKAGE_URL)
    # Downloading pre-built CM Package
    file (MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install)
    ExternalProject_Add(cm-emu
      URL               ${CM_PACKAGE_URL}
      CONFIGURE_COMMAND ""
      BUILD_COMMAND     ""
      UPDATE_COMMAND    ""
      INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install
      INSTALL_COMMAND   ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/cm-emu-prefix/src/cm-emu/ <INSTALL_DIR>
      BUILD_BYPRODUCTS  ${LIBCM} ${LIBIGFXCMRT_EMU}
    )
  else()
    # Build from CM source tree fetched from github
    if (MSVC)
      message(FATAL_ERROR "Online-building of CM_EMU library is not supported under Windows environment")
    else()
      # Arguments for online patching to suppress log message from CM_EMU
      # Replacing CM_EMU's log print-out macro controlled by 'GFX_EMU_WITH_FLAGS_'
      # with blank space from $CM_EMU_SRC/common/emu_log.h
      set (replacing_pattern s/{\ ?GFX_EMU_WITH_FLAGS_.*//g)
      ExternalProject_Add(cm-emu
        GIT_REPOSITORY    https://github.com/intel/cm-cpu-emulation.git
        GIT_TAG           f9d167edbcb995e713d5a8
        BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_build
        INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install
        PATCH_COMMAND     perl -pi.back -e ${replacing_pattern} ${CMAKE_CURRENT_BINARY_DIR}/cm-emu-prefix/src/cm-emu/common/emu_log.h
        CMAKE_ARGS        -DLIBVA_INSTALL_PATH=/usr
                          -D__SYCL_EXPLICIT_SIMD_PLUGIN__=true
                          -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
        BUILD_BYPRODUCTS  ${LIBCM} ${LIBIGFXCMRT_EMU}
      )
    endif()
  endif()
endif ()
ExternalProject_Add_Step(cm-emu llvminstall
  COMMAND ${CMAKE_COMMAND} -E make_directory ${LLVM_BINARY_DIR}/pi_esimd_emulator_deps && ${CMAKE_COMMAND} -E copy_directory <INSTALL_DIR>/ ${LLVM_BINARY_DIR}/pi_esimd_emulator_deps
  COMMENT "Installing cm-emu into the LLVM binary directory"
  DEPENDEES install
)

include_directories(${LLVM_BINARY_DIR}/pi_esimd_emulator_deps/include/igfxcmrt_emu)
include_directories(${LLVM_BINARY_DIR}/pi_esimd_emulator_deps/include/libcm/cm)

# Compilation flag to exclude lines in header files imported from CM
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__SYCL_EXPLICIT_SIMD_PLUGIN__")

set(CMAKE_CXX_STANDARD 17)

# Compilation option modification to prevent build termination caused by
# warnings from CM-imported files
if (MSVC)
string(REPLACE "/W4" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
else()
string(REPLACE "-pedantic" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

add_sycl_plugin(esimd_emulator
  SOURCES
    "${sycl_inc_dir}/CL/sycl/detail/pi.h"
    "pi_esimd_emulator.cpp"
  LIBRARIES
    "${LEVEL_ZERO_LOADER}"
    ${LIBCM}
    ${LIBIGFXCMRT_EMU}
    #TODO remove cyclic dependency
    sycl
)

add_dependencies(pi_esimd_emulator cm-emu)

set_target_properties(pi_esimd_emulator PROPERTIES LINKER_LANGUAGE CXX)

# Copy CM Header files to $(INSTALL)/include/sycl/CL/
install(DIRECTORY    ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install/include/libcm/cm/
        DESTINATION  ${SYCL_INCLUDE_DIR}/sycl/CL
        COMPONENT    libcmrt-headers
        FILES_MATCHING PATTERN "*.h"
)

# Copy '.so' files to '$(INSTALL)/lib'
if (MSVC)
  install(DIRECTORY   ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install/lib/
          DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
          COMPONENT   libcmrt-libs
          FILES_MATCHING PATTERN "*.lib"
  )
  install(DIRECTORY   ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install/bin/
          DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
          COMPONENT   libcmrt-dlls
          FILES_MATCHING PATTERN "*.dll"
  )
else()
  install(DIRECTORY   ${CMAKE_CURRENT_BINARY_DIR}/cm-emu_install/lib/
          DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
          COMPONENT   libcmrt-sos
          FILES_MATCHING PATTERN "*.so"
  )
endif()
