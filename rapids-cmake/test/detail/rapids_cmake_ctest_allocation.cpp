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

#include <rapids_cmake_ctest_allocation.hpp>

#include <cuda_runtime_api.h>

#include <algorithm>
#include <cstdlib>
#include <numeric>
#include <string>
#include <string_view>

namespace rapids_cmake {

namespace {
GPUAllocation defaultGPUAllocation() {
  int dev_id = 0;
  auto error_v = cudaGetDevice(&dev_id);
  if (error_v == cudaSuccess)
    return GPUAllocation{dev_id, 1};
  return GPUAllocation{0, 1};
}

GPUAllocation parseCTestAllocation(std::string_view env_variable) {
  std::string gpu_resources{std::getenv(env_variable.begin())};
  // need to handle parseCTestAllocation variable being empty

  // need to handle parseCTestAllocation variable not having some
  // of the requested components

  // The string looks like "id:<number>,slots:<number>"
  auto id_start = gpu_resources.find("id:") + 3;
  auto id_end = gpu_resources.find(",");
  auto slot_start = gpu_resources.find("slots:") + 6;

  auto id = gpu_resources.substr(id_start, id_end - id_start);
  auto slots = gpu_resources.substr(slot_start);

  return GPUAllocation{std::stoi(id), std::stoi(slots)};
}

std::vector<GPUAllocation> determineGPUAllocations() {
  std::vector<GPUAllocation> allocations;
  const auto *resource_count = std::getenv("CTEST_RESOURCE_GROUP_COUNT");
  if (!resource_count) {
    allocations.push_back(std::move(defaultGPUAllocation()));
    return allocations;
  }

  const auto resource_max = std::stoi(resource_count);
  for (int index = 0; index < resource_max; ++index) {
    std::string group_env = "CTEST_RESOURCE_GROUP_" + std::to_string(index);
    std::string resource_group{std::getenv(group_env.c_str())};
    std::transform(resource_group.begin(), resource_group.end(),
                   resource_group.begin(), ::toupper);

    if (resource_group == "GPUS") {
      auto resource_env = group_env + "_" + resource_group;
      auto &&allocation = parseCTestAllocation(resource_env);
      allocations.push_back(std::move(allocation));
    }
  }

  return allocations;
}
} // namespace

std::vector<GPUAllocation> full_allocation() {
  return determineGPUAllocations();
}

std::vector<int> gpu_ids() {
  auto gpus = determineGPUAllocations();
  std::vector<int> gids;
  gids.reserve(gpus.size());
  std::transform(gpus.begin(), gpus.end(), std::back_inserter(gids),
                 [](GPUAllocation &ga) -> int { return ga.device_id; });

  return gids;
}

int bind_to_gpu(GPUAllocation const &alloc) {
  return cudaSetDevice(alloc.device_id);
}

int bind_to_gpu(int const &gpuId) { return cudaSetDevice(gpuId); }

bool bind_to_first_gpu() {
  std::vector<GPUAllocation> allocs = determineGPUAllocations();
  if (allocs.empty()) {
    return false;
  }
  return (bind_to_gpu(allocs[0]) == cudaSuccess);
}

} // namespace rapids_cmake
