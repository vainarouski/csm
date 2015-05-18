#!/bin/bash
#
# Commands to execute json_test.rb
#
# Options:
#
# optional:
# --test_schema_folder or -i - Relative path to the test schema folder, default value: ./etc
# --report_folder or -o - Relative path to the output report file folder, default value: ./reports
# --hostname or -h - The hostname of the test environment, default value: commonsensemedia.org
# --method or -m - Test API method, default value: browse
# --key or -k -  Test API key, default value: fd4b46050e5eea76085349c6458e149d
# --limit or -l - Number of feeds which will be tested, default value: nil
# --dryrun or -d - Test script using local test.json file, default value: false
#
# required for all:
#  --category or -c - Test API category
#
# required for reviews and lists:
#  --channel or -n - Test API channel
#
#To install all necessary gems, uncomment bundle install
# bundle install

ruby ./lib/json_test.rb --category reviews --channel movie --limit 2 --dryrun
