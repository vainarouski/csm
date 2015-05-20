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
  end


  def url
    default_url = "http://api.#{@test_parameters[:hostname]}/api/v2/#{@test_parameters[:category]}/#{@test_parameters[:method]}?api_key=#{@test_parameters[:key]}&channel=#{@test_parameters[:channel]}"
    unless @test_parameters[:limit].nil?
      default_url += "&limit=#{@test_parameters[:limit].chomp}"
    end

    default_url
  end


  def json_respond

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    if response.code == "200"
      response.body
    else
      raise "ERROR!!! URl: #{uri} is unreachable!"
    end
  end


  def json_test
    test_report = {}
    test_report[:start_time] = Time.now
    parsed_test_json.each do |feed|
      errors = JSON::Validator.fully_validate(parsed_json_schema, feed)
      error_messages = []
      errors.each do |error|
        /The property \'(.+?)\' (.+?) in/.match error
        error_message = {}
        error_message[:property] = Regexp.last_match[1]
        error_message[:message] = Regexp.last_match[2]
        error_messages << error_message
      end
      test_report[feed["id"]] = error_messages
    end

    test_reporter(test_report)
  end


  def parsed_json_schema
    begin
      json_schema_name = "#{@test_parameters[:test_schema_folder]}/#{@test_parameters[:category]}_#{@test_parameters[:channel]}.json"
      json_file = File.open(json_schema_name).read
      JSON.parse(json_file)

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
      else
        test_json = json_respond
      end

      JSON.parse(test_json)

  rescue Errno::ENOENT => fe
    raise "Test JSON not found!!! Error: " + fe.to_s
  rescue Exception => e
    raise "Test JSON parse error!!! Error: " + e.to_s
    end
  end


  def test_reporter(test_report)
    html = TestReportWriter.html_builder(test_report)
    File.write("#{@test_parameters[:report_folder].chomp}/report.html", html)
  end
end



if (__FILE__ == $0)

  test_title = "Common Sense Media JSON test"
  default_schema_folder = "./etc"
  default_report_folder = "./reports"
  default_hostname = "commonsensemedia.org"
  default_method = "browse"
  default_key = "fd4b46050e5eea76085349c6458e149d"
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
  opt :limit, "Number of feeds which will be tested", :short => "-l", :type => :string, :default => default_limit
  opt :dryrun, "Test script using local test.json file", :short => "-d", :type => :boolean, :default => false

  opt :category, "Test API category", :short => "-c", :type => :string
  opt :channel, "Test API channel", :short => "-n", :type => :string
  end


  # option validation
  Trollop::die :category, "Test API category missed or incorrect!" unless (categories.include?(opts[:category].chomp))

  if opts[:category] == "reviews" || opts[:category] =="lists"
    Trollop::die :channel, "Test API channel missed or incorrect!" unless (channels.include?(opts[:channel].chomp))
    Trollop::die :test_schema_folder, "Test schema folder or file incorrect!" unless (File.exists?("#{opts[:test_schema_folder]}/#{opts[:category]}_#{opts[:channel]}.json"))
  else
    Trollop::die :test_schema_folder, "Test schema folder or file incorrect!" unless (File.exists?("#{opts[:test_schema_folder]}/#{opts[:category]}.json"))
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

