include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libssh2/libssh2
    REF 6c7769dcc422250d14af1b06fce378b6ee009440
    SHA512 fa34c598149d28b12f5cefbee4816f30a807a1bde89faa3be469f690057cf2ea7dd1a83191b2a2cae3794e307d676efebd7a31d70d9587e42e0926f82a1ae73d
    HEAD_REF master
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-Fix-UWP.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_ZLIB_COMPRESSION=OFF
        -DDENABLE_DEBUG_LOGGING=ON
        -DCMAKE_CXX_FLAGS_RELEASE=/MT
        -DCMAKE_C_FLAGS_RELEASE=/MT
        -DCRYPTO_BACKEND=WinCNG
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libssh2)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh2 RENAME copyright)

vcpkg_copy_pdbs()
