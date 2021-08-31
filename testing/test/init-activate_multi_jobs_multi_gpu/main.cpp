
#include <iostream>
#include <vector>
namespace rapids_cmake::test {
bool rapids_test_is_first_gpu_bound();
}
int main() {
  if (rapids_cmake::bind_to_first_gpu()) {
    std::cout << "bound to a GPU" << std::endl;
  }
  return 0;
}
