#!/usr/bin/env bash

# Checkout the YAML test from Elasticsearch tag
travis/checkout_yaml_test.pl

# Run YAML tests
test/run_yaml_tests.pl