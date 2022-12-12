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
rapids_test_detect_number_of_gpus
----------------------------------

.. versionadded:: v23.02.00

Detect the number of GPUs on the local machine

  .. code-block:: cmake

    rapids_test_detect_number_of_gpus( result_variable )

Builds a small test CUDA executable that reports the number of GPUs
on the machine

#]=======================================================================]
function(rapids_test_detect_number_of_gpus result_variable)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.detect_number_of_gpus")

  set(eval_file ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus.cpp)
  set(eval_exe ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus)
  set(error_file ${PROJECT_BINARY_DIR}/rapids-cmake/detect_gpus.stderr.log)
  if(NOT DEFINED CMAKE_CUDA_COMPILER AND NOT DEFINED CMAKE_CXX_COMPILER)
    message(STATUS "rapids_test_detect_number_of_gpus no C++ or CUDA compiler enabled, presuming 1 GPU."
    )
    set(rapids_gpu_count 1)
  else()
    if(EXISTS "${eval_exe}")
      execute_process(COMMAND ${eval_exe} OUTPUT_VARIABLE rapids_gpu_count)
    else()
      if(NOT EXISTS "${eval_file}")
        file(WRITE ${eval_file}
             [=[
  #include <cuda_runtime_api.h>
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
      execute_process(COMMAND ${compiler} ${eval_file} -o ${eval_exe} -I${CUDAToolkit_INCLUDE_DIRS}
                              -L${CUDAToolkit_LIBRARY_DIR} -lcudart ERROR_FILE ${error_file})
      if(NOT EXISTS "${eval_exe}")
        message(STATUS "rapids_test_detect_number_of_gpus failed to build detection executable, presuming 1 GPU."
        )
        message(STATUS "rapids_test_detect_number_of_gpus compile failure details found in ${error_file}"
        )
      else()
        execute_process(COMMAND ${eval_exe} OUTPUT_VARIABLE rapids_gpu_count)
      endif()
    endif()
  endif()
  set(${result_variable} ${rapids_gpu_count} PARENT_SCOPE)

endfunction()
