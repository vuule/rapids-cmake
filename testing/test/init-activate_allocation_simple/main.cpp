
#include <iostream>
#include <vector>

#include "rapids_cmake_ctest_allocation.hpp"

int main() {
  if ( rapids_cmake::using_resources() && rapids_cmake::bind_to_first_gpu()) {
    auto allocs = rapids_cmake::full_allocation();
    if(allocs.size() == 1 && allocs[0].slots == 100)
    {
      std::cout << "using all of one GPU" << std::endl;
      return 0;
    }
  }
  return 1;
}
