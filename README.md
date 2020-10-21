# Common Sense Media Json API validator

This script designed specifically to test json version of API for https://www.commonsensemedia.org/. The script created 
with help of Ruby programming language and implemented as command line tool. The script makes a REST API call, receives
json response and validates received response against json schema. Results of script execution presented in an output 
html report.

## Prerequisites

Before proceeding to script execution you should preinstall version of Ruby programming language. The best way to do it 
is to install version control system and install the latest stable version of programming language with help of this system.

If you familiar with different version control systems you can use any system of your choice. If you are not familiar 
with any of them you can try to use RVM (more details can be found here: https://rvm.io/).

To install RVM you can simply run next command from command line interface:
```
\curl -sSL https://get.rvm.io | bash -s stable --ruby
```
To use RVM right after installation you need to restart your command line tool or open need tab or just execute:
```
source /Users/[you home folder]/.rvm/scripts/rvm
```
To check a list of installed Ruby versions:
```
rvm list
``` 
You should be able to see something like:
```
=* ruby-2.7.0 [ x86_64 ]

# => - current
# =* - current && default
#  * - default
```

If you see this output, you have Ruby version 2.7 installed in your system. To confirm it, check version of Ruby in command line:
```
 ✗ ruby -v
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-darwin19]
``` 
With the next step you need to install bundler - the library which allows installing Ruby gems from GemFile:  
```
gem install bundler
```
As the last step you need to install all required gems, make sure you run it from csm folder where Gemfile located:
```
bundler install
```

Make sure all gems installed without errors. Json gems uses native extension, if you are getting an error here, possible 
solution will be Xcode installation with updated command line tool. Please do a search for installation instructions for 
your particular MacOs version.

Please note: Installation instructions above provided for Mac OS, the script still should work fine on Windows, but you 
need to figure out same installation steps adapted for Windows.

## How to run script

As mentioned before, script implemented as a command line tool, and can be executed from command line with a list of possible options.
For simplicity special file run_scipt.sh was created. In this file you can find example of run command.

To run this file you need just execute:
```
sh run_script.sh
```

The uncommented command in a file will be executed (make sure "#" is removed in the beginning of the line).

Command options:

Required option for all:

*  --category or -c - Test API category

Optional: 

* -- test_schema_folder or -i - Relative path to the test schema folder inside repository, default value: ./etc
* -- report_folder or -o - Relative path to the output report file folder inside repository, default value: ./reports
* -- hostname or -h - The hostname of the test environment, default value: commonsensemedia.org
* -- method or -m - Test API method, default value: browse
* -- key or -k -  Test API key, default value: fd4b46050e5eea76085349c6458e149d
* -- limit or -l - Number of feeds which will be tested, default value: nil
* -- dryrun or -d - Test script using local test.json file, default value: false
* -- secured or -s Use secured URL, default => false
* -- key_type or -t Test API key type, possible values: testing or partner, default: testing

## Script structure

* **_etc_** folder contains all json schemas for json responses. Since we have a slightly different response based on key,
we have two separate folder for partner key and for testing key. A lot of elements presented in both responses with 
testing and partner keys, to reduce the amount of duplicated elements common folder was created. Mostly, if not all, json
schemas from **_partner_key_** and **_testing_key_** folders contains references on elements in common folder. Potentially,
if some change is required, with adjustment in common folder, all elements should be updated for all responses. Please note, some
responses contains same elements but structure of these elements is different. For those elements file name contains 
underscore with a partial path to distinguish them. For example, _stars_root_ and _stars_stats_ - we have two elements stars
one located in a root of response and another one inside _stats_ element.
* **_lib_** folder contains the script code. `json_test.rb` - main script file with all source code. 
`test_report_writer.rb` - file for report writer. if you would like to change report style or update some html elements
 inside report you probably would like to review this file first.
* `gitignore` the file responsible fir files visible for git repository. If you would like to hide something from hide, you
need to specify them here. 
* `GemFile` file where all required Ruby gems specified
* `GemFile.lock` Bundler generated file where recorded the exact versions of gems that were installed
* `run_script.sh` bash file to simpify test run from command line





