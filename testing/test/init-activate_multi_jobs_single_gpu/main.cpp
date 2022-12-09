
#include <iostream>
#include <vector>
#include <chrono>
#include <thread>

#include <fcntl.h>
#include <unistd.h>

#include "detail/file_locker.hpp"

int main(int argc, char** argv) {
  const constexpr int min_lock_id = 0;
  const constexpr int max_lock_id = 5;


  // Lock our sentinel file
  auto my_id = std::...(argv[1]);
  auto lock = ctest_lock(argv[1]);

  // verify all sentinel files are locked
  auto checker = [alloc](int lock_state, int i) {
    bool valid_lock_state = false;
    if (i == my_id) {
      // we have this file locked
      valid_lock_state = (lock_state == 0);
    } else {
      // some other process has this file locked
      valid_lock_state = (lock_state == -1);
    }
    std::cout << i << " lock_state: " << lock_state << " valid " << valid_lock_state << std::endl;
    return valid_lock_state;
  };
  bool all_locked = validate_locks(checker, min_lock_id, max_lock_id);
  // unlock and return
  unlock(lock);
  return (all_locked) ? 0 : 1;
}
