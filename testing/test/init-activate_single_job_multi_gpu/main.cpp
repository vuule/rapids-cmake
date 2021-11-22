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
      threads.emplace_back(std::thread(task, std::forward<Arguments>(args)...));
    }
    for (auto& t : threads)
    {
      t.join();
    }
  }

  bool bind_to_ctest_allocated_gpu() {
    static std::vector<rapids_cmake::GPUAllocation> ctest_allocation;
    static int index = 0;
    static std::mutex _mutex;

    bool bound = false;
    {
        std::lock_guard<std::mutex> lk(_mutex);
        if(index == 0) { ctest_allocation = rapids_cmake::full_allocation(); }
        if( rapids_cmake::using_resources() ) {
          rapids_cmake::bind_to_gpu(ctest_allocation[index++]);
          bound = true;
        }
    }
    return bound;
  }

  int main(int, char**)
  {
    spawn_n(ctest_allocation.size(), [ctest_allocation&](std::size_t index) {
    //only bind if ctest specified
    bind_to_ctest_allocated_gpu();


    });
  }