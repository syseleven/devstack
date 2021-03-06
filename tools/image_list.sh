#!/bin/bash

# Keep track of the DevStack directory
TOP_DIR=$(cd $(dirname "$0")/.. && pwd)

# The following "source" implicitly calls get_default_host_ip() in
# stackrc and will die if the selected default IP happens to lie
# in the default ranges for FIXED_RANGE or FLOATING_RANGE. Since we
# do not really need HOST_IP to be properly set in the remainder of
# this script, just set it to some dummy value and make stackrc happy.
HOST_IP=SKIP
source $TOP_DIR/functions

# Possible virt drivers, if we have more, add them here. Always keep
# dummy in the end position to trigger the fall through case.
DRIVERS="openvz ironic libvirt vsphere xenserver dummy"

# Extra variables to trigger getting additional images.
export ENABLED_SERVICES="h-api,tr-api"
HEAT_FETCHED_TEST_IMAGE="Fedora-i386-20-20131211.1-sda"
PRECACHE_IMAGES=True

# Loop over all the virt drivers and collect all the possible images
ALL_IMAGES=""
for driver in $DRIVERS; do
    VIRT_DRIVER=$driver
    URLS=$(source $TOP_DIR/stackrc && echo $IMAGE_URLS)
    if [[ ! -z "$ALL_IMAGES" ]]; then
        ALL_IMAGES+=,
    fi
    ALL_IMAGES+=$URLS
done

# Make a nice list
echo $ALL_IMAGES | tr ',' '\n' | sort | uniq

# Sanity check - ensure we have a minimum number of images
num=$(echo $ALL_IMAGES | tr ',' '\n' | sort | uniq | wc -l)
if [[ "$num" -lt 5 ]]; then
    echo "ERROR: We only found $num images in $ALL_IMAGES, which can't be right."
    exit 1
fi
