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
generate_compute_allocation
---------------------------

.. versionadded:: v22.02.00

Generate a target which holds the C++ static library code to
extract the CTest resource allocation requests and activate
the request CUDA GPUs.

  .. code-block:: cmake

    generate_compute_allocation( namespace target_name )

Builds a static library that holds the C++ logic that will code to
extract the CTest resource allocation requests and activate
the requested CUDA GPUs.

This target will not activate the C++ logic, that needs to be done
manually by calling the `rapids_test_bind_to_first_gpu` function
as shown in the below example.

.. code-block:: cpp

  #include "rapids_cmake_ctest_allocation.hpp"
  int main(int argc, char** argv) {
    bool rapids_test_activated = rapids_cmake::bind_to_first_gpu();
    if( rapids_test_activated ) {
      // execute tests
    }
    return 0;
  }

#]=======================================================================]

function(rapids_test_generate_compute_allocation namespace alias_name)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.generate_main")
  set(target_name rapids_${alias_name})

  if(NOT TARGET ${target_name})
    set(source "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/rapids_cmake_ctest_allocation.cpp")
    add_library(${target_name} STATIC ${source})
    if(NOT TARGET CUDA::toolkit)
      find_package(CUDAToolkit REQUIRED)
    endif()
    target_include_directories(${target_name} PUBLIC "${CMAKE_CURRENT_FUNCTION_LIST_DIR}")
    target_link_libraries(${target_name} PRIVATE CUDA::cudart_static)
    target_compile_features(${target_name} PRIVATE cxx_std_17)
  endif()
  if(NOT TARGET "${namespace}::${alias_name}")
    add_library("${namespace}::${alias_name}" ALIAS ${target_name})
  endif()
endfunction()
