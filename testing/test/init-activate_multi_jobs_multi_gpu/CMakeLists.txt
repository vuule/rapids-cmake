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
cmake_minimum_required(VERSION 3.20)
project(rapids-test-project LANGUAGES CXX)

include(${rapids-cmake-dir}/rapids-test.cmake)

rapids_test_init()

find_package(CUDAToolkit REQUIRED)

add_executable(verify_multi_concurrent main.cpp)
target_link_libraries(verify_multi_concurrent PRIVATE RAPIDS::test CUDA::toolkit)
target_include_directories(verify_multi_concurrent PRIVATE "${rapids-cmake-testing-dir}/test/")
target_compile_definitions(verify_multi_concurrent PRIVATE "BINARY_DIR=${CMAKE_BINARY_DIR}")

enable_testing()

foreach(v RANGE 5)
  add_test(NAME concurrent_test_${v} COMMAND verify_multi_concurrent)
  # that way our tests have slot values of 20, 21, 22, ...
  # which when run in parallel will take at most 2 GPUs to execute
  rapids_test_gpu_requirements(concurrent_test_${v} GPUS 1 PERCENT 2${v})
endforeach()

