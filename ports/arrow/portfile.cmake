include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "Apache Arrow only supports x64")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow
    REF apache-arrow-0.11.1
    SHA512 8a2de7e4b40666e4ea7818fac488549f1348e961e7cb6a4166ae4019976a574fd115dc1cabaf44bc1cbaabf15fb8e5133c8232b34fca250d8ff7c5b65c5407c8
    HEAD_REF master
)

set(CPP_SOURCE_PATH "${SOURCE_PATH}/cpp")

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/all.patch"
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" ARROW_BUILD_STATIC)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" IS_STATIC)

if (IS_STATIC)
    set(PARQUET_ARROW_LINKAGE static)
else()
    set(PARQUET_ARROW_LINKAGE shared)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CPP_SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DARROW_BUILD_TESTS=off
    -DRAPIDJSON_HOME=${CURRENT_INSTALLED_DIR}
    -DFLATBUFFERS_HOME=${CURRENT_INSTALLED_DIR}
    -DARROW_ZLIB_VENDORED=ON
    -DBROTLI_HOME=${CURRENT_INSTALLED_DIR}
    -DLZ4_HOME=${CURRENT_INSTALLED_DIR}
    -DZSTD_HOME=${CURRENT_INSTALLED_DIR}
    -DSNAPPY_HOME=${CURRENT_INSTALLED_DIR}
    -DBOOST_ROOT=${CURRENT_INSTALLED_DIR}
    -DGFLAGS_HOME=${CURRENT_INSTALLED_DIR}
    -DZLIB_HOME=${CURRENT_INSTALLED_DIR}
    -DARROW_PARQUET=ON
    -DARROW_BUILD_STATIC=${ARROW_BUILD_STATIC}
    -DARROW_BUILD_SHARED=${ARROW_BUILD_SHARED}
    -DBUILD_STATIC=${ARROW_BUILD_STATIC}
    -DBUILD_SHARED=${ARROW_BUILD_SHARED}
    -DPARQUET_ARROW_LINKAGE=${PARQUET_ARROW_LINKAGE}
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib ${CURRENT_PACKAGES_DIR}/lib/arrow.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/arrow_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/arrow.lib)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/arrow_static.lib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/arrow RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
