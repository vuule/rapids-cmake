
#include <iostream>
#include <vector>


int main() {

  // Very we only have a single GPU visible to us
  int nDevices = 0;
  cudaGetDeviceCount(&nDevices);

  if (nDevices == 0) {
    return 1;
  }
  std::cout << "Seeing at least a single GPU" << std::endl;
  return 0;
}
