#!/bin/bash
set -e

# This script runs Test Kitchen tests using Docker

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${GREEN}==== $1 ====${NC}\n"
}

# Function to run tests
run_test() {
    local platform=$1
    local suite=$2
    
    echo -e "${YELLOW}Testing $platform with suite $suite${NC}"
    
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(pwd):/cookbook \
        -w /cookbook \
        --privileged \
        ruby:2.7 \
        bash -c "
            apt-get update && \
            apt-get install -y docker.io sudo && \
            gem install bundler && \
            bundle install && \
            KITCHEN_YAML=kitchen.docker.yml bundle exec kitchen test $platform-$suite --destroy=always || exit 1
        "
        
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Test on $platform-$suite passed${NC}"
    else
        echo -e "${RED}✗ Test on $platform-$suite failed${NC}"
        exit 1
    fi
}

# List available platforms and suites
print_header "Available Test Kitchen Instances"
docker run --rm \
    -v $(pwd):/cookbook \
    -w /cookbook \
    ruby:2.7 \
    bash -c "
        gem install bundler && \
        bundle install && \
        KITCHEN_YAML=kitchen.docker.yml bundle exec kitchen list
    "

# Run tests for key platforms and suites
print_header "Running Tests"

# By default, just test Ubuntu 20.04 with default suite
# You can add more tests by uncommenting the lines below
run_test "ubuntu-20-04" "default"
# run_test "debian-11" "default"
# run_test "almalinux-8" "default"
# run_test "amazonlinux-2" "default"

# Additional suite tests
# run_test "ubuntu-20-04" "distributed"
# run_test "ubuntu-20-04" "thrift"
# run_test "ubuntu-20-04" "rest"

print_header "All Tests Completed Successfully!"