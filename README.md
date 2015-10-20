# Dynamic inventory for Ansible with OpenStack

Read about it in the [blog post](https://blog.codecentric.de/en/2014/06/provisioning-iaas-clouds-dynamic-ansible-inventories-openstack-metadata/).

The script has been udpated since publishing the blog post. It now supports more recent versions of `python-novalcient`. In addtion to the description in the blog post, the updated version of the script requires the environment variable `OS_COMPUTE_API_VERSION` to be set to either `1.1`, `2`, or `3` according to your OpenStack installation, e.g., `OS_COMPUTE_API_VERSION=1.1`.

