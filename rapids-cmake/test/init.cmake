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
single-gpu tests in parallel on multi-gpu machines.

<todo>
 document quickly the json file format

.. note::
    To ensure that tests are run on a subset of GPUs, the `CUDA_VISIBLE_DEVICES`
    enviornment variable will need to be set when executing CMake so that
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