
add_custom_target(libcxx-generate-public-header-transitive-inclusion-tests
    COMMAND "${Python3_EXECUTABLE}" "${LIBCXX_SOURCE_DIR}/utils/generate_header_inclusion_tests.py"
    COMMENT "Generate tests checking for mandated transitive includes in public headers.")

add_custom_target(libcxx-generate-public-header-tests
    COMMAND "${Python3_EXECUTABLE}" "${LIBCXX_SOURCE_DIR}/utils/generate_header_tests.py"
    COMMENT "Generate tests for including public headers.")

add_custom_target(libcxx-generate-feature-test-macros
    COMMAND "${Python3_EXECUTABLE}" "${LIBCXX_SOURCE_DIR}/utils/generate_feature_test_macro_components.py"
    COMMENT "Generate the <version> header and tests for feature test macros.")

add_custom_target(libcxx-generate-private-header-tests
    COMMAND "${Python3_EXECUTABLE}" "${LIBCXX_SOURCE_DIR}/utils/generate_private_header_tests.py"
    COMMENT "Generate tests for ensuring that detail headers are private.")

add_custom_target(libcxx-generate-assertion-tests
    COMMAND "${Python3_EXECUTABLE}" "${LIBCXX_SOURCE_DIR}/utils/generate_assertion_tests.py"
    COMMENT "Generate tests for inclusion of <__assert>.")

add_custom_target(libcxx-generate-files
    DEPENDS libcxx-generate-public-header-transitive-inclusion-tests
            libcxx-generate-public-header-tests
            libcxx-generate-feature-test-macros
            libcxx-generate-private-header-tests
            libcxx-generate-assertion-tests
    COMMENT "Create all the auto-generated files in libc++ and its tests.")
