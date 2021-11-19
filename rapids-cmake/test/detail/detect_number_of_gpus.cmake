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

  set(eval_file ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus.cu)
  set(eval_exe ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus)
  set(error_file ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus.stderr.log)
  if(NOT DEFINED CMAKE_CUDA_COMPILER AND NOT DEFINED CMAKE_CXX_COMPILER)
    message(STATUS "rapids_test_detect_number_of_gpus no C++ or CUDA compiler enabled, presuing 1 GPU.")
    set(rapids_gpu_count 1)
  else()
    if(EXISTS "${eval_exe}")
      execute_process(COMMAND ${eval_exe} OUTPUT_VARIABLE rapids_gpu_count)
      message(STATUS "rapids_test_detect_number_of_gpus:  execute_process")
    else()
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

      find_package(CUDAToolkit)
      set(compiler ${CMAKE_CXX_COMPILER})
      if(DEFINED CMAKE_CUDA_COMPILER)
        set(compiler ${CMAKE_CUDA_COMPILER})
      endif()
      execute_process(COMMAND ${compiler} -o ${eval_exe} -I${CUDAToolkit_INCLUDE_DIRS}
                      ERROR_FILE ${error_file})
      execute_process(COMMAND ${eval_exe} OUTPUT_VARIABLE rapids_gpu_count)
    endif()
  endif()
  set(${result_variable} ${rapids_gpu_count} PARENT_SCOPE)

endfunction()
