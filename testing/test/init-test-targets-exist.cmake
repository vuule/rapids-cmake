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
include(${rapids-cmake-dir}/test/init.cmake)
include(${rapids-cmake-dir}/test/init.cmake)

enable_language(CUDA)

rapids_test_init()

if(NOT TARGET RAPIDS::test)
  message(FATAL_ERROR "rapids_test_init failed to generate the RAPIDS::test target")
endif()

if(NOT TARGET RAPIDS::test_auto_activate)
  message(FATAL_ERROR "rapids_test_init failed to generate the RAPIDS::test_auto_activate target")
endif()

# verify it can be called multiple times without issue
rapids_test_init()
