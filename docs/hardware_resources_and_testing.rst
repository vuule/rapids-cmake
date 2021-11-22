:orphan:

.. _cpm_resource_allocation:

Hardware Resources and Testing
##############################


Resource Allocation
*******************

CTest resource allocation frameworks allow tests to specify which hardware resources that they need, and for projects to specify the specific local/machine resources available.
Combined together this ensures that tests are told which specific resources they should use, and ensures over-subscription won't occur no matter the requested testing parallel level.

To get CTest resource allocation tests setup the following components are needed.

  - A json per-machine resource specification file
  - The :cmake:variable:`CTEST_RESOURCE_SPEC_FILE` points to the json file
  - Each test records what resources it requires via test properties
  - Each test reads the relevant environment variables to determine
    what specific resources it should use


These are steep requirements that require large amounts of infrastructure
setup for each project. On-top of that the CTest resource allocation
specification is very relaxed, allowing for it to be used to represent
hardware like CPUs, GPUs, and ASICs, and also things like databases which have unique constraints like number of concurrent users.

rapids_test
***********

To help RAPIDS projects utilize all GPUs on a machine when running tests,
the ``rapids-cmake`` project offers a suite of rapids_test commands
that simplify GPU detection, setting up resource specification files,
specifying test requirements and setting the active CUDA GPU.

Machine GPU Detection
*********************

The key component of CTest resource allocation is having an accurate
representation of the hardware that exists on the developers machine.
The :cmake:command:`rapids_test_init` function will do system introspection
to determine the number of GPUs on the current machine and generate
a resource allocation json file representation these GPUs.

The CTest resource allocation specification isn't limited to representing
GPUs a single unit. Instead it allows the json file to specify the capacity ( slots )
that each GPU has. In the case of rapids-cmake we always represent
each GPU as having 100 slots allowing projects to think in percentage of
a GPU when calculating requirements.


Specifying Per Tests GPU Requirements
*************************************


Setting Tests 'active' GPU
**************************


Multi GPU Tests
***************
