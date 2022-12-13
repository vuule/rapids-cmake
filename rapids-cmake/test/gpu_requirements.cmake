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
rapids_test_gpu_requirements
----------------------------

.. versionadded:: v23.02.00

States how many GPUs and what percent of each a test requires.

  .. code-block:: cmake

    rapids_test_gpu_requirements( test_name GPUS <N> [PERCENT <value>])

This function should only be used when :cmake:command:`rapids_test_add` is
insufficient due to the rapids-cmake test wrappers not working for your
project.

When combined with :cmake:command:`rapids_test_init` informs CTest what
resources should be allocated to a test so that when testing in parallel
oversubscription doesn't occur. Without this information user execution of
CTest with high parallel levels will cause multiple tests to run on the
same GPU and quickly exhaust all memory.


``GPUS``
  State how many GPUs this test requires. Allows CTest to not over-subscribe
  a machine's hardware.

``PERCENT``
  State how much of each GPU this test requires. In general 100, 50, and 20
  are commonly used values. By default if no percent is provided, 100 is
  used.

#]=======================================================================]
function(rapids_test_gpu_requirements test_name)
  set(options)
  set(one_value GPUS PERCENT)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS_TEST "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set(gpus ${_RAPIDS_TEST_GPUS})
  if(NOT gpus)
    message(FATAL_ERROR "rapids_test_gpu_requirements requires the GPUS option to be provided.")
  endif()
  if(gpus LESS 1 OR (NOT gpus MATCHES "^[0-9]+$"))
    message(FATAL_ERROR "rapids_test_gpu_requirements GPUS requires a numeric value (>= 1) provided ${gpus}."
    )
  endif()

  set(percent 100)
  if(DEFINED _RAPIDS_TEST_PERCENT)
    set(percent ${_RAPIDS_TEST_PERCENT})
  endif()

  # verify that percent is inside the allowed bounds
  if(percent GREATER 100 OR percent LESS 1 OR (NOT percent MATCHES "^[0-9]+$"))
    message(FATAL_ERROR "rapids_test_gpu_requirements requires a numeric PERCENT value [1-100].")
  endif()

  set_property(TEST ${test_name} PROPERTY RESOURCE_GROUPS "${gpus},gpus:${percent}")

endfunction()
