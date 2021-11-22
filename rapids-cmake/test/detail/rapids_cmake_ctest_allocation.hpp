/*
 * Copyright (c) 2021, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once

#include <vector>

namespace rapids_cmake {

/*
* Represents a GPU Allocation provided by a CTest resource specification.
*
* The `device_id` maps to the CUDA gpu id required by `cudaSetDevice`.
* The slots represent the percentage of the GPU that this test will use.
* Primarily used by CTest to ensure proper load balancing of tests.
*/
struct GPUAllocation {
  int device_id;
  int slots;
};

/*
 * Returns true when a CTest resource specification has been specified.
 *
 * Since the vast majority of tests should execute without a CTest resource
 * spec ( e.g. when executed manually be developer ), callers of `rapids_cmake`
 * should first ensure that a CTestresource spec file has been provided before
 * trying to query/bind to the allocation.
 *
 * ```cxx
 *   if( rapids_cmake::using_resouces()) {
 *     rapids_cmake::bind_to_first_gpu();
 *     }
 * ```
*/
bool using_resources();

/*
 * Returns all GPUAllocations allocated for a test
 *
 * To support multi-gpu tests the CTest resource specification allows a
 * test to request multiple GPUs. As CUDA only allows binding to a
 * single GPU at any time, this API allows tests to know what CUDA
 * devices they should bind to.
 *
 * Note: The `device_id` of each allocation might not be unique.
 * If a test says they need 50% of two gpu's they could be allocated
 * the same physical GPU. If a test needs distinct / unique devices
 * they must request 51%+ of a device.
 *
 * Note: rapids_cmake does no caching, so this query should be cached
 * instead of called multiple times.
*/
std::vector<GPUAllocation> full_allocation();

/*
 * Have CUDA bind to a given GPUAllocation
 *
 * Have CUDA bind to the `device_id` specified in the CTest
 * GPU allocation
 *
 * Note: Return value is the cudaError_t of `cudaSetDevice`
 */
int bind_to_gpu(GPUAllocation const &alloc);

/*
 * Convience method to bind to the first GPU that CTest has allocated
 * Provided as most RAPIDS tests only require a single GPU
 *
 * Note: Return value is the cudaError_t of `cudaSetDevice`
 */
bool bind_to_first_gpu();

} // namespace rapids_cmake
