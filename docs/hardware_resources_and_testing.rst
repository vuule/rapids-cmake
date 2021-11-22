
.. _rapids_resource_allocation:

Hardware Resources and Testing
##############################


Resource Allocation
*******************

CTest resource allocation frameworks allow tests to specify which hardware resources that they need, and for projects to specify the specific local/machine resources available.
Combined together this ensures that tests are told which specific resources they should use, and ensures over-subscription won't occur no matter the requested testing parallel level.

To get CTest resource allocation used by tests the following components are needed.

  - A json per-machine resource specification file
  - The :cmake:variable:`CTEST_RESOURCE_SPEC_FILE` points to the json file
  - Each :cmake:command:`add_test` records what resources it requires via test properties
  - Each test reads the relevant environment variables to determine
    what specific resources it should use


These are steep requirements that require large amounts of infrastructure
setup for each project. In addition the CTest resource allocation specification is very
relaxed, allowing it to represent abitrary requirements such as CPUs, GPUs, and ASICs.

rapids_test
***********

To help RAPIDS projects utilize all GPUs on a machine when running tests, the ``rapids-cmake``
project offers a suite of rapids_test commands that simplify GPU detection, setting up
resource specification files, specifying test requirements, and setting the active CUDA GPU.

Machine GPU Detection
*********************

The key component of CTest resource allocation is having an accurate representation of the
hardware that exists on the developers machine. The :cmake:command:`rapids_test_init` function
will do system introspection to determine the number of GPUs on the current machine and generate
a resource allocation json file representation these GPUs.

.. code-block:: cmake

  include(${CMAKE_BINARY_DIR}/RAPIDS.cmake)

  include(rapids-test)

  enable_testing()
  rapids_test_init()

The CTest resource allocation specification isn't limited to representing GPUs a single unit.
Instead it allows the json file to specify the capacity ( slots ) that each GPU has. In the
case of rapids-cmake we always represent each GPU as having 100 slots allowing projects to
think in total percentage when calculating requirements.


Specifying Per Tests GPU Requirements
*************************************

As talked about above each CMake test needs to specify the GPU resources they require
to allow CTest to properly partition GPUs given the CTest parallel level. To make this easy for developers rapids-cmake offers the :cmake:command:`rapids_test_gpu_requirements` which
makes it easy to state how many GPUs each test needs, and what percentage of said GPUs they will use.

For example below we have three tests, two which can run concurrently on the same GPU and one that requires a full GPU. This specification will allow all three tests to run concurently when
a machine has 2+ GPUs.

.. code-block:: cmake

  include(${CMAKE_BINARY_DIR}/RAPIDS.cmake)

  include(rapids-test)

  enable_testing()
  rapids_test_init()

  add_executable( cuda_test test.cu )
  target_link_libraries( cuda_test PRIVATE RAPIDS::test )

  add_test(NAME test_small_alloc COMMAND cuda_test 50)
  add_test(NAME test_medium_alloc COMMAND cuda_test 100)
  add_test(NAME test_medium_very_larg_alloc COMMAND cuda_test 10000)

  rapids_test_gpu_requirements(test_small_alloc GPUS 1 PERCENT 10)
  rapids_test_gpu_requirements(test_medium_alloc GPUS 1 PERCENT 20)
  rapids_test_gpu_requirements(test_very_large_alloc GPUS 1 PERCENT 100)

Setting Tests Active GPU
**************************

To properly use the CTest allocated resources, C++ tests need to bind to the reserved GPU
instead of using the default device as provided by CUDA. To make this easier rapids-cmake
offers a C++ API in "rapids_cmake_ctest_allocation.hpp" ( Offered by the `RAPIDS::test` target ).

For tests that require a single GPU the following C++ code should be used:

.. code-block:: cpp

int main(int, char**) {
  // Only bind to the CTest provided GPU when executed via 'ctest'
  if ( rapids_cmake::using_resources()) {
    rapids_cmake::bind_to_first_gpu();
  }
  // The rest of your `int main()` logic

  return 0;
}


.. _rapids_multi_gpu_allocation:

Multi GPU Tests
***************

The C++ API in "rapids_cmake_ctest_allocation.hpp" ( Offered by the `RAPIDS::test` target ) also supports tests that require multiple GPU bindings. But before that lets quickly go
over the two primary patterns for GPU testing and how you would use :cmake:command:`rapids_test_gpu_requirements` to set them up.

  * You want acquire full utilization on two (or more) GPUs without anything else running.
    This is accomplished by stating you require 100% of two ( ore more) GPUs.

  * You want two ( or more ) partial GPU allocations to verify CUDA features like
    'Per Thread CUDA Stream'. In this case you don't care if you are allocated multiple
    distinct GPUs but need to support such an allocation if given to you. This is
    accomplished by specifying a GPU percentage amount less than 50% so that both
    allocations can be provided by the same phyical GPU.


In the below CMake example `test_mutli_gpu` represents the first case, and `test_cuda_streams`
the second.

.. code-block:: cmake

  include(${CMAKE_BINARY_DIR}/RAPIDS.cmake)

  include(rapids-test)

  enable_testing()
  rapids_test_init()

  add_executable( mult_gpu mtest.cu )
  target_link_libraries( mult_gpu PRIVATE RAPIDS::test )

  add_executable( test_streams stest.cu )
  target_link_libraries( test_streams PRIVATE RAPIDS::test )

  add_test(NAME test_mutli_gpu COMMAND mult_gpu)
  rapids_test_gpu_requirements(test_very_large_alloc GPUS 2)

  add_test(NAME test_cuda_streams COMMAND test_streams)
  rapids_test_gpu_requirements(test_cuda_streams GPUS 6 PERCENT 10)


Now onto the C++ side!

