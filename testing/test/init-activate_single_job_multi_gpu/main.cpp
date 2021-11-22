
#include <thread>
#include <vector>

#include "rapids_cmake_ctest_allocation.hpp"

template <typename Task, typename... Arguments>
void spawn_n(std::size_t num_threads, Task task, Arguments&&... args)
{
  std::vector<std::thread> threads;
  threads.reserve(num_threads);
  for (std::size_t i = 0; i < num_threads; ++i)
  {
    threads.emplace_back(std::thread(task, i, std::forward<Arguments>(args)...));
  }
  for (auto& t : threads)
  {
    t.join();
  }
}

int main(int, char**)
{
  auto ctest_allocation = rapids_cmake::full_allocation();
  spawn_n(6, [ctest_allocation&](std::size_t index) {
    if( rapids_cmake::using_resources() ) {
      rapids_cmake::bind_to_gpu(ctest_allocation[index]);
    }
    //...
  });

  return 0;
}