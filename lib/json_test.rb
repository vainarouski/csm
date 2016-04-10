require "rubygems"
require "json"
require "net/http"
require "uri"
require 'json-schema'
require 'trollop'
require 'pry'

require_relative 'test_report_writer'
include TestReportWriter


class JsonValidator


  def initialize(test_parameters = {})
    @test_parameters = test_parameters
    @verbose = test_parameters[:verbose]
  end


  def url
    if @test_parameters[:secured] == true
      protocol = "https"
    else
      protocol = "http"
    end

    if @test_parameters[:channel].nil?
      default_url = "#{protocol}://#{@test_parameters[:hostname]}/v2/#{@test_parameters[:category]}/#{@test_parameters[:method]}?api_key=#{@test_parameters[:key]}&format=json"
    else
      default_url = "#{protocol}://#{@test_parameters[:hostname]}/v2/#{@test_parameters[:category]}/#{@test_parameters[:method]}?api_key=#{@test_parameters[:key]}&channel=#{@test_parameters[:channel]}&format=json"
    end

    unless @test_parameters[:limit].nil?
      default_url += "&limit=#{@test_parameters[:limit].chomp}"
    end

    verbose_message("Generated url: #{default_url}") if @verbose

    default_url
  end


  def json_respond


    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    if @test_parameters[:secured] == true
      http.use_ssl = true
    end

    verbose_message("Loading json repond...") if @verbose

    response = http.request(request)


    if response.code == "200"

      verbose_message("Json repond successfully loaded.") if @verbose

      response.body

    else
      raise "ERROR!!! URl: #{uri} is unreachable!"
    end
  end


  def json_test


    test_report = {}
    test_report[:start_time] = Time.now
    index = 1
    json_file = parsed_test_json
    json_schema = parsed_json_schema

    verbose_message("Testing json file against json schema...") if @verbose
    verbose_message("Tested feeds: ") if @verbose

    json_file.each do |feed|
      errors = JSON::Validator.fully_validate(json_schema, feed)
      error_messages = []

      errors.each do |error|
        /The property \'(.+?)\' (.+?) in/.match error
        error_message = {}
        error_message[:property] = Regexp.last_match[1]
        error_message[:message] = Regexp.last_match[2]
        error_messages << error_message
      end


      print "\r#{index}" if @verbose

      index += 1

      test_report[feed["id"]] = error_messages
    end

    verbose_message("") if @verbose

    test_reporter(test_report)
  end


  def parsed_json_schema
    begin

      verbose_message("Parsing json schema...") if @verbose

      if @test_parameters[:channel].nil?
        json_schema_name = "#{@test_parameters[:test_schema_folder]}/#{@test_parameters[:key_type]}_key/#{@test_parameters[:category]}.json"
      else
        json_schema_name = "#{@test_parameters[:test_schema_folder]}/#{@test_parameters[:key_type]}_key/#{@test_parameters[:category]}_#{@test_parameters[:channel]}.json"
      end

      json_file = File.open(json_schema_name).read
      parsed_schema = JSON.parse(json_file)

      verbose_message("Json schema successfully parced.") if @verbose

      parsed_schema

    rescue Errno::ENOENT => fe
      raise "JSON schema file not found!!! Error: " + fe.to_s
    rescue Exception => e
      raise "JSON schema parse error!!! Error: " + e.to_s
    end
  end


  def parsed_test_json
    begin

      if @test_parameters[:dryrun] == true
        test_json = File.open("#{@test_parameters[:test_schema_folder].chomp}/test.json").read

        verbose_message("Dryrun mode, using #{@test_parameters[:test_schema_folder].chomp}/test.json") if @verbose
      else
        test_json = json_respond
      end

      verbose_message("Parsing json file...") if @verbose

      parced_file = JSON.parse(test_json)

      verbose_message("Json file successfully parced.") if @verbose

      parced_file

    rescue Errno::ENOENT => fe
    raise "Test JSON not found!!! Error: " + fe.to_s
  rescue Exception => e
    raise "Test JSON parse error!!! Error: " + e.to_s
    end
  end


  def test_reporter(test_report)

    verbose_message("Building test report...") if @verbose

    html = TestReportWriter.html_builder(test_report)
    unless @test_parameters[:channel].nil?
      file_name = "#{@test_parameters[:report_folder].chomp}/#{Time.now.strftime("%m_%d_%Y_%H:%M:%S")}_#{@test_parameters[:category]}_#{@test_parameters[:channel]}.html"
    else
      file_name = "#{@test_parameters[:report_folder].chomp}/#{Time.now.strftime("%m_%d_%Y_%H:%M:%S")}_#{@test_parameters[:category]}.html"
    end

    File.write(file_name, html)

    verbose_message("Test Report created: #{file_name}") if @verbose
  end

  def verbose_message(message)
    puts message
  end
end



if (__FILE__ == $0)

  test_title = "Common Sense Media JSON test"
  default_schema_folder = "./etc"
  default_report_folder = "./reports"
  default_hostname = "api.commonsensemedia.org"
  default_method = "browse"
  default_key = "fd4b46050e5eea76085349c6458e149d"
  default_key_type = "testing"
  default_limit = nil


  #TODO: Need to add category for Learning Ratings
  categories = ["reviews", "lists", "videos", "new"]
  channels = ["movie", "book", "app", "game", "tv", "music", "website"]

  opts = Trollop::options do
    banner <<-EOS
#{test_title}
    #{$0} [options]
Where options are:

    EOS
  opt :test_schema_folder, "Relative path to the test schema folder inside repository", :short => "-i", :default => default_schema_folder
  opt :report_folder, "Relative path to the output report file folde inside repositoryr", :short => "-o", :type => :string, :default => default_report_folder
  opt :hostname, "The hostname of the test environment", :short => "-h", :type => :string, :default => default_hostname
  opt :method, "Test API method", :short => "-m", :type => :string, :default => default_method
  opt :key, "Test API key", :short => "-k", :type => :string, :default => default_key
  opt :key_type, "Test API key type", :short => "-t", :type => :string, :default => default_key_type
  opt :limit, "Number of feeds which will be tested", :short => "-l", :type => :string, :default => default_limit
  opt :dryrun, "Test script using local test.json file", :short => "-d", :type => :boolean, :default => false
  opt :verbose, "Verbose mode", :short => "-v", :type => :boolean, :default => true
  opt :secured, "Use secured URL", :short => "-s", :type => :boolean, :default => false
  opt :category, "Test API category", :short => "-c", :type => :string
  opt :channel, "Test API channel", :short => "-n", :type => :string
  end


  # option validation
  Trollop::die :category, "Test API category missed or incorrect!" unless (categories.include?(opts[:category].chomp))

  if opts[:category] == "reviews"
    Trollop::die :channel, "Test API channel missed or incorrect!" unless (channels.include?(opts[:channel].chomp))
    Trollop::die :test_schema_folder, "Test schema folder or file incorrect!" unless (File.exists?("#{opts[:test_schema_folder]}/#{opts[:key_type]}_key/#{opts[:category]}_#{opts[:channel]}.json"))
  else
    Trollop::die :test_schema_folder, "Test schema folder or file incorrect!" unless (File.exists?("#{opts[:test_schema_folder]}/#{opts[:key_type]}_key/#{opts[:category]}.json"))
  end

  # Check if report_folder exist, if not create it
  folder = opts[:report_folder]
  unless Dir.exist?(folder)
    folders = folder.chomp.split("/")
    path = "./"
    folders.each do |subfolder|
      next if subfolder == '.'
      path += "#{subfolder}/"
      unless Dir.exist?(path)
        Dir.mkdir(path)
      end
    end
  end

 JsonValidator.new(opts).json_test

end

