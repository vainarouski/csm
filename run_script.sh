#!/bin/bash
#
# Commands to execute json_test.rb
#
# Options:
#
# optional:
# --test_schema_folder or -i - Relative path to the test schema folder inside repository, default value: ./etc
# --report_folder or -o - Relative path to the output report file folder inside repository, default value: ./reports
# --hostname or -h - The hostname of the test environment, default value: commonsensemedia.org
# --method or -m - Test API method, default value: browse
# --key or -k -  Test API key, default value: fd4b46050e5eea76085349c6458e149d
# --limit or -l - Number of feeds which will be tested, default value: nil
# --dryrun or -d - Test script using local test.json file, default value: false
# --secured or -s Use secured URL, default => false
#
# required for all:
#  --category or -c - Test API category
#
# required for reviews and lists:
#  --channel or -n - Test API channel
#
#To install all necessary gems, uncomment bundle install
# bundle install
#
ruby ./lib/json_test.rb -h "api-qa.commonsense.org" -k "404da1a207199d7ed5d9f0d887827982" --category reviews -l 10 --channel movie --report-folder ./reports/reviews_movie
#ruby ./lib/json_test.rb  -h "qa.commonsensemedia.org" -s --category reviews --channel game --report-folder ./reports/reviews_game
#ruby ./lib/json_test.rb -h "qa.commonsensemedia.org" -s --category reviews --channel app --report-folder ./reports/reviews_app
#ruby ./lib/json_test.rb -h "qa.commonsensemedia.org" -s --category reviews --channel website --report-folder ./reports/reviews_website
#ruby ./lib/json_test.rb -h "qa.commonsensemedia.org" -s --category reviews --channel tv --report-folder ./reports/reviews_tv
#ruby ./lib/json_test.rb -h "qa.commonsensemedia.org" -s --category reviews --channel book --report-folder ./reports/reviews_book
#ruby ./lib/json_test.rb -h "qa.commonsensemedia.org" -s --category reviews --channel music --report-folder ./reports/reviews_music
#ruby ./lib/json_test.rb -s -h "qa.commonsensemedia.org" --category lists --report-folder ./reports/lists
#ruby ./lib/json_test.rb -s -h "qa.commonsensemedia.org" --category new --report-folder ./reports/new
#ruby ./lib/json_test.rb -s -h "qa.commonsensemedia.org" --category videos --report-folder ./reports/videos
