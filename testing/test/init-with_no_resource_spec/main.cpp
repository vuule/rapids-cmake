
#include <iostream>
#include <vector>

#include "rapids_cmake_ctest_allocation.hpp"

int main() {
  if(!rapids_cmake::using_resources() ) {
    std::cout << "failed to have a resource file" << std::endl;
    return 0;
  }
  return 1;
}
