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
rapids_test_detect_number_of_gpus
----------------------------------

.. versionadded:: v22.02.00

Detect the number of GPUs on the local machine

  .. code-block:: cmake

    rapids_test_detect_number_of_gpus( result_variable )

Builds a small test CUDA executable that reports the number of GPUs
on the machine

#]=======================================================================]

function(rapids_test_detect_number_of_gpus result_variable)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.detect_number_of_gpus")

  # Unset this first in case it's set to <empty_string> Which can happen inside rapids
  set(eval_file ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus.cu)
  set(eval_exe ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus)
  set(error_file ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus.stderr.log)

  set(rapids_gpu_count 1)

  if(EXISTS "${eval_exe}")
    execute_process(COMMAND ${eval_exe} OUTPUT_VARIABLE rapids_gpu_count)
  elseif(DEFINED CMAKE_CUDA_COMPILER)

    if(NOT EXISTS "${eval_file}")
      file(WRITE ${eval_file}
[=[
#include <cstdio>
int main(int, char**) {
  int nDevices = 0;
  cudaGetDeviceCount(&nDevices);
  printf("%d", nDevices);
  return 0;
}
]=])
    endif()

    execute_process(COMMAND ${CMAKE_CUDA_COMPILER} -std=c++11 -o ${eval_exe} --run ${eval_file}
                    OUTPUT_VARIABLE rapids_gpu_count OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_FILE ${error_file})
  endif()

  set(${result_variable} ${rapids_gpu_count} PARENT_SCOPE)

endfunction()
