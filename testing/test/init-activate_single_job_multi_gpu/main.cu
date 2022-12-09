
#include <iostream>
#include <vector>


int main() {
  int nDevices = 0;
  cudaGetDeviceCount(&nDevices);

  //We should have anywhere from 1 to 2 devices allocated
  std::cout << "Seeing " << nDevices << " GPU devices" << std::endl;

  if (nDevices == 0 || nDevices > 2) {
    return 1;
  }
  return 0;
}
