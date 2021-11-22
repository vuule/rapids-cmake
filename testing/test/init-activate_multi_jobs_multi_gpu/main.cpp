
#include <chrono>
#include <iostream>
#include <thread>
#include <vector>

#include <fcntl.h>
#include <unistd.h>

#include <cuda_runtime_api.h>

#include "detail/file_locker.hpp"
#include "rapids_cmake_ctest_allocation.hpp"

int main() {
  const constexpr int min_lock_id = 20;
  const constexpr int max_lock_id = 25;

  // first verify our allocation
  auto allocations = rapids_cmake::full_allocation();
  if (allocations.size() != 1) {
    std::cerr << "Incorrect number of GPU allocation, was expecting 1"
              << std::endl;
    return 1;
  }
  auto &alloc = allocations[0];
  if (alloc.slots < min_lock_id || alloc.slots > max_lock_id) {
    std::cerr << alloc.slots << std::endl;
    std::cerr << "Incorrect portion of GPU allocation, was expecting a value "
                 "between 20 - 25"
              << std::endl;
    return 1;
  }

  // check how many GPUs we have.
  // if we have 1 gpu we don't want to do anything
  int nDevices = 0;
  cudaGetDeviceCount(&nDevices);

  if (nDevices < 2) {
    std::cout << "Detected: " << nDevices
              << " CUDA devices, while we require 2+" << std::endl;
    return 0;
  }

  if( rapids_cmake::using_resources() ) {
    rapids_cmake::bind_to_gpu(alloc);
  }

  // Lock our sentinel file
  auto lock = ctest_lock(alloc);

  // verify all sentinel files are locked
  auto checker = [alloc](int lock_state, int i) {
    bool valid_lock_state = false;
    if (i == alloc.slots) {
      // we have this file locked
      valid_lock_state = (lock_state == 0);
    } else {
      // some other process has this file locked
      valid_lock_state = (lock_state == -1);
    }
    std::cout << i << " lock_state: " << lock_state << " valid "
              << valid_lock_state << std::endl;
    return valid_lock_state;
  };
  bool all_locked = validate_locks(checker, min_lock_id, max_lock_id);
  // unlock and return
  unlock(lock);
  return (all_locked) ? 0 : 1;
}
