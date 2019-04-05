#!/bin/bash

. ./assert.sh continue_on_error     # Load test functions with continue_on_error/stop_on_error

. ./sampleTest1.sh                  # sample1
. ./sampleTest2.sh                  # sample2
. ./backend_test/backend_test.sh            # Tests for terraform backend
