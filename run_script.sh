#!/bin/bash
#
#Commands to execute json_test.rb
#
#Options:
# --test_schema_folder or -i - Relative path to the test schema folder, default value: ./etc
# --report_folder or -o - Relative path to the output report file folder, default value: ./reports
# --hostname or -h - The hostname of the test environment, default value: commonsensemedia.org
# --method, "Test API method", :short => "-m", :type => :string, :default => default_method
# --key, "Test API key", :short => "-k", :type => :string, :default => default_key
# --limit, "Number of feeds which will be tested", :short => "-l", :type => :string, :default => default_limit
# --dryrun, "Test script using local test.json file", :short => "-d", :type => :boolean, :default => false

  --category, "Test API category", :short => "-c", :type => :string
  --channel, "Test API channel", :short => "-n", :type => :string
#
#To install all necessary gems, uncomment bundle install
#
# bundle install
  ruby ./lib/json_test.rb --category reviews --channel movie --limit 2
