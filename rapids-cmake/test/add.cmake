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
rapids_test_add
---------------

.. versionadded:: v23.02.00

States how many GPUs and what precent of each a test requires

  .. code-block:: cmake

    rapids_test_add(NAME <name> COMMAND <target|command> [<args>...]
                    GPUS <N> [PERCENT <value>]
                    [WORKING_DIRECTORY <dir>])

Add a test called `<name>` which will be executed with a given GPU
resource allocation.

When combined with :cmake:command:`rapids_test_init` informs CTest what
resources should be allocated to a test so that when testing in parallel
oversubscription doesn't occur. Without this information user execution of
CTest with high parallel levels will cause multiple tests to run on the
same GPU and quickly exhaust all memory.

``COMMAND``
  Specify the test command-line. If <command> specifies an executable target
  (created by add_executable()) it will automatically be replaced by the location of the
  executable created at build time.

``GPUS``
  State how many GPUs this test requires. Allows CTest to not over-subscribe
  a machines hardware.

``PERCENT``
  By default if no percent is provided, 100 is used.
  State how much of each GPU this test requires.

``WORKING_DIRECTORY``
  Specify the working directory in which to execute the test. If not specified the test will
  be run with the current working directory set to the value of :cmake:variable:`CMAKE_CURRENT_BINARY_DIR <cmake:variable:CMAKE_CURRENT_BINARY_DIR>`.


#]=======================================================================]
function(rapids_test_add)
  set(options)
  set(one_value NAME WORKING_DIRECTORY GPUS PERCENT)
  set(multi_value COMMAND)
  cmake_parse_arguments(_RAPIDS_TEST "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT DEFINED _RAPIDS_TEST_NAME)
    message(FATAL_ERROR "rapids_add_test called without a name")
  endif()

  if(NOT DEFINED _RAPIDS_TEST_COMMAND)
    message(FATAL_ERROR "rapids_add_test called without a command")
  endif()

  list(POP_FRONT _RAPIDS_TEST_COMMAND command)
  set(args "${_RAPIDS_TEST_COMMAND}")
  if(TARGET ${command})
    set(command "$<TARGET_FILE:${command}>")
  endif()

  if(NOT DEFINED _RAPIDS_TEST_WORKING_DIRECTORY)
    set(_RAPIDS_TEST_WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
  endif()

  # Provide a copy of the test runner in the binary directory so that tests still can be executed if
  # for some reason rapids-cmake src has been removed.
  set(_rapids_run_gpu_test_script "${PROJECT_BINARY_DIR}/rapids-cmake/run_gpu_test.cmake")
  if(NOT EXISTS "${_rapids_run_gpu_test_script}")
    file(COPY "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/run_gpu_test.cmake"
         DESTINATION "${PROJECT_BINARY_DIR}/rapids-cmake/")
  endif()

  add_test(NAME ${_RAPIDS_TEST_NAME}
           COMMAND ${CMAKE_COMMAND} "-Dcommand_to_run=${command}" "-Dcommand_args=${args}" -P
                   "${_rapids_run_gpu_test_script}"
           WORKING_DIRECTORY "${_RAPIDS_TEST_WORKING_DIRECTORY}")

  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/gpu_requirements.cmake)
  rapids_test_gpu_requirements(${_RAPIDS_TEST_NAME} GPUS ${_RAPIDS_TEST_GPUS}
                               PERCENT ${_RAPIDS_TEST_PERCENT})

endfunction()
