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
add_cmake_config_test( rapids-test.cmake )

add_cmake_config_test(generate_resource_spec-invalid-mode.cmake SHOULD_FAIL "rapids_test_generate_resource_spec currently only supports the 'DETECT'")
add_cmake_config_test(generate_resource_spec-no-gpus.cmake)
add_cmake_config_test(generate_resource_spec-simple.cmake)

set(percent_error_message "rapids_test_gpu_requirements requires a numeric PERCENT value [1-100].")
set(gpu_error_message "rapids_test_gpu_requirements GPUS requires a numeric value")
set(gpu_missing_message "rapids_test_gpu_requirements requires the GPUS option to be provided.")
add_cmake_config_test(gpu_requirements-char-percent.cmake SHOULD_FAIL "${percent_error_message}")
add_cmake_config_test(gpu_requirements-char-gpu.cmake SHOULD_FAIL "${gpu_error_message}")
add_cmake_config_test(gpu_requirements-max-percent.cmake)
add_cmake_config_test(gpu_requirements-min-percent.cmake)
add_cmake_config_test(gpu_requirements-multi.cmake)
add_cmake_config_test(gpu_requirements-negative-percent.cmake SHOULD_FAIL "${percent_error_message}")
add_cmake_config_test(gpu_requirements-negative-gpu.cmake SHOULD_FAIL "${gpu_error_message}")
add_cmake_config_test(gpu_requirements-no-gpus.cmake SHOULD_FAIL "${gpu_missing_message}")
add_cmake_config_test(gpu_requirements-no-percent.cmake)
add_cmake_config_test(gpu_requirements-over-max-percent.cmake SHOULD_FAIL "${percent_error_message}")
add_cmake_config_test(gpu_requirements-single.cmake)
add_cmake_config_test(gpu_requirements-zero-percent.cmake SHOULD_FAIL "${percent_error_message}")

add_cmake_config_test(init-existing-specfile.cmake)
add_cmake_config_test(init-simple.cmake)

add_cmake_ctest_test(init-activate_allocation_simple)
add_cmake_ctest_test(init-activate_multi_jobs_multi_gpu)
add_cmake_ctest_test(init-activate_multi_jobs_single_gpu)
add_cmake_ctest_test(init-impossible_allocation SHOULD_FAIL "Insufficient resources for test")


# need a test where we don't write ctest_resource_spec
# verify that we have an empty gpu allocation vector

# need a test where we mark a test as having 50 slots
# of a single gpu. verify slots extraction is correct

# need a test where we mark a test as having 0 GPU's
# but we have a resource spec, verify slots/empty is correct

# need a test where we mark a test we mark 1 gpu
# and verify slots is marked at 100%
