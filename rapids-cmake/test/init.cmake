#=============================================================================
# Copyright (c) 2021, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_test_init
----------------

.. versionadded:: v22.02.00

Establish necessary components for CTest gpu resource allocation to allow
for parallel tests

  .. code-block:: cmake

    rapids_test_init(  )

Generates a json resource specification file representing the machines GPUs
using system introspection. This will allow CTest to schedule multiple
single-gpu or multi-gpu tests in parallel on multi-gpu machines.

For tests to execute correctly on the assigned GPU they need to bind
to the reserved/allocated GPU. For C++ projects rapids-cmake provides
an API to make this easy.

On the CMake side the tests will need to link to the `RAPIDS::test` target:

.. code-block:: cmake

  target_link_libraries(<cxx_test_program> PRIVATE RAPIDS::test)

This will allow the C++ test to use the rapids_cmake C++ API. For tests
that require a single GPU the following C++ code should be used. If
you test requires multiple GPUs please read the C++ API documentation
found in `rapids_cmake_test_allocation.hpp` for guidance.

.. code-block:: cpp
int main(int, char**) {
  // Only bind to the CTest provided GPU when executed via 'ctest'
  if ( rapids_cmake::using_resources()) {
    rapids_cmake::bind_to_first_gpu();
  }
  // The rest of your `int main()` logic

  return 0;
}

.. note::
    To ensure that tests are run on a subset of GPUs, the `CUDA_VISIBLE_DEVICES`
    environment variable will need to be set when executing CMake so that
    the generated json file is aware of what GPUs to use.

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`CTEST_RESOURCE_SPEC_FILE` will be set to the generated
  json file if not already set

#]=======================================================================]
function(rapids_test_init )
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.init")

  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/generate_resource_spec.cmake)
  rapids_test_generate_resource_spec(DESTINATION "${PROJECT_BINARY_DIR}/resource_spec.json" DETECT)

  if(NOT CTEST_RESOURCE_SPEC_FILE)
    set(CTEST_RESOURCE_SPEC_FILE "${PROJECT_BINARY_DIR}/resource_spec.json" PARENT_SCOPE)
  endif()


  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/generate_compute_allocation.cmake)
  rapids_test_generate_compute_allocation(RAPIDS test)

endfunction()
