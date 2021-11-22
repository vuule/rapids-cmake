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

set(CTEST_RESOURCE_SPEC_FILE "fake-value-to-stop-generation")
rapids_test_init()
unset(CTEST_RESOURCE_SPEC_FILE)

add_executable(verify_alloc_hook main.cpp)
target_link_libraries(verify_alloc_hook PRIVATE RAPIDS::test)

enable_testing()
add_test(NAME simple_test COMMAND verify_alloc_hook)
rapids_test_gpu_requirements(simple_test GPUS 1)

# Validate that the test runs correctly
set_tests_properties(simple_test
  PROPERTIES PASS_REGULAR_EXPRESSION "failed to have a resource file"
  )
