
#include <iostream>
#include <vector>

#include "rapids_cmake_ctest_allocation.hpp"

int main() {
  if ( rapids_cmake::using_resources() && rapids_cmake::bind_to_first_gpu()) {
    std::cout << "bound to a GPU" << std::endl;
  }
  return 0;
}
