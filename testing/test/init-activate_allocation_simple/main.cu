
#include <iostream>
#include <vector>


int main() {

  // Very we only have a single GPU visible to us
  int nDevices = 0;
  cudaGetDeviceCount(&nDevices);

  std::cout << "Seeing " << nDevices << " GPU devices" << std::endl;

  if (nDevices == 0 || nDevices > 3) {
    return 1;
  }
  return 0;
}
