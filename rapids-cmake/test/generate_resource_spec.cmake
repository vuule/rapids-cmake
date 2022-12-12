#=============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
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
rapids_test_generate_resource_spec
----------------------------------

.. versionadded:: v23.02.00

Generates a json resource specification file representing the machines GPUs
using system introspection.

  .. code-block:: cmake

    rapids_test_generate_resource_spec( DESTINATION filepath DETECT)

Generates a json resource specification file representing the machines GPUs
using system introspection. This will allow CTest to schedule multiple
single-gpu tests in parallel on multi-gpu machines.

For the majority of projects :cmake:command:`rapids_test_init` should be used.
This command should be used directly projects that require multiple spec
files to be generated.

``DESTINATION``

``DETECT``

.. note::
    Unlike rapids_test_init this doesn't set CTEST_RESOURCE_SPEC_FILE

#]=======================================================================]
function(rapids_test_generate_resource_spec DESTINATION filepath mode)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.generate_resource_spec")

  if(NOT mode STREQUAL "DETECT")
    message(FATAL_ERROR "rapids_test_generate_resource_spec currently only supports the 'DETECT' mode"
    )
  endif()

  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/detect_number_of_gpus.cmake)

  rapids_test_detect_number_of_gpus(gpu_count)

  file(READ "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/resource_spec.json" gpu_json_template)

  if(gpu_count GREATER 0)
    # cmake-lint: disable=E1120
    foreach(gpu_index RANGE ${gpu_count})
      if(gpu_index EQUAL gpu_count)
        # foreach in inclusive of the max
        break()
      endif()
      # Enable this GPU id by giving it 100 slots
      string(JSON gpu_json_template SET "${gpu_json_template}" local 0 gpus ${gpu_index} slots 100)
    endforeach()
  endif()

  file(WRITE "${filepath}" "${gpu_json_template}")

endfunction()
