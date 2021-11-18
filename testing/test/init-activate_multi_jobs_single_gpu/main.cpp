
#include <iostream>
#include <vector>
#include <chrono>
#include <thread>

#include <fcntl.h>
#include <unistd.h>

#include "rapids_cmake_ctest_allocation.hpp"

struct ctest_lock {
  std::string file_name;
  int fd;
};

std::string lock_file_name(int v) {
  return std::string("lock." + std::to_string(v));
}

ctest_lock construct_lock(rapids_cmake::GPUAllocation const &alloc) {
  const std::string path = lock_file_name(alloc.slots);
  auto fd = open(path.c_str(), O_RDWR | O_CREAT, S_IRGRP | S_IRWXU);
  if (fd == -1) {
    exit(1);
  }

  auto deviceIdAsStr = std::to_string(alloc.device_id);
  write(fd, deviceIdAsStr.c_str(), deviceIdAsStr.size());
  lockf(fd, F_TLOCK, 0);
  return ctest_lock{std::move(path), fd};
}

template<typename LockValidator>
bool validate_locks(LockValidator lock_checker, int min_lock_id,
                    int max_lock_id) {

  using namespace std::chrono_literals;

  // barrier
  // wait for all other tests to lock the respective sentinel file
  std::this_thread::sleep_for(5000ms);

  int valid_count = 0;
  for (int i = min_lock_id; i <= max_lock_id; ++i) {
    auto path = lock_file_name(i);
    auto fd = open(path.c_str(), O_RDONLY);
    auto lock_state = lockf(fd, F_TEST, 0);

    bool valid_lock_state = lock_checker(lock_state, i);
    if (valid_lock_state) {
      ++valid_count;
    }
  }
  // barrier again so nothing unlocks while other are checking
  // for a lock
  std::this_thread::sleep_for(2000ms);

  return (valid_count == ((max_lock_id+1) - min_lock_id));
}

void unlock(ctest_lock &lock) { close(lock.fd); }

int main() {
  const constexpr int min_lock_id = 10;
  const constexpr int max_lock_id = 15;

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
                 "between 10 - 15"
              << std::endl;
    return 1;
  }

  rapids_cmake::bind_to_gpu(alloc);

  // Lock our sentinel file
  auto lock = construct_lock(alloc);
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
    return valid_lock_state;
  };
  bool all_locked = validate_locks(checker, min_lock_id, max_lock_id);
  // unlock and return
  unlock(lock);
  return (all_locked) ? 0 : 1;
}
