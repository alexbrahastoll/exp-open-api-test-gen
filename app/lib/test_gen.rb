require 'yaml'
require 'net/http'

# g = TestGen.new('app/lib/cities_meteorological_info_openapi.yml'); g.generate_and_run_tests

class TestGen
  attr_reader :open_api_spec_path, :open_api_spec, :api_base_url
  attr_accessor :report

  def initialize(path)
    @open_api_spec_path = path
    @report = {}
  end

  def generate_and_run_tests
    @open_api_spec = YAML.load(File.read(open_api_spec_path))

    @api_base_url = open_api_spec.dig('servers', 0, 'url')
    api_paths = open_api_spec.dig('paths')

    print "\n\nStarting to generate and run tests for #{open_api_spec_path}\n\n"

    api_paths.each do |path, path_metadata|
      10.times do
        gen_and_run_tests_for(path, path_metadata)
      end
    end

    print_report
  end

  private

  def gen_and_run_tests_for(path, path_metadata)
    # We only support GET requests at the current moment.
    return unless path_metadata.has_key?('get')

    generated_params = gen_params(path_metadata.dig('get', 'parameters'))
    concrete_path = path.dup
    generated_params.each do |gen_param|
      concrete_path.gsub!(/\{#{gen_param[:name]}\}/, gen_param[:gen_value])
    end

    url = URI.escape("#{api_base_url}#{concrete_path}")
    url = URI(url)
    req = Net::HTTP::Get.new(url)
    res =
      Net::HTTP.start(url.host, url.port, use_ssl: false) do |http|
        http.request(req)
      end

    parsed_body = JSON.parse(res.body)
    successful_response_schema_path =
      path_metadata.dig('get', 'responses', '200', 'content', 'application/json', 'schema', '$ref').
        gsub('#/', '').
        split('/')
    successful_response_body_schema = open_api_spec.dig(*successful_response_schema_path)

    log_test_run(req, res)
    check_response_body_types(req, parsed_body, successful_response_body_schema)
  end

  def gen_params(params)
    params.map do |param|
      {
        name: param['name'],
        gen_value: send("gen_#{param.dig('schema', 'type')}_value", param)
      }
    end
  end

  def gen_string_value(param)
    if param.dig('schema', 'enum').present?
      param.dig('schema', 'enum').sample
    else
      gen_random_string_value
    end
  end

  def gen_random_string_value
    ['a', 'b', 'c', '1', '2', '3', '$', '&', '*'].sample(6).join
  end

  def check_response_body_types(req, res_body, expected_response_schema)
    res_body.each do |field, value|
      expected_type = expected_response_schema.dig('properties', field, 'type')
      expected_type = from_open_api_to_ruby_type(expected_type)
      actual_type = value.class

      if actual_type != expected_type
        log_type_mismatch(req, field, actual_type, expected_type)
      end
    end
  end

  def from_open_api_to_ruby_type(open_api_type)
    {
      'string' => String,
      'integer' => Integer
    }[open_api_type]
  end

  def log_test_run(req, res)
    report[req] ||= []
    res_status = res.code.to_i

    log_entry =
      if res_status >= 200 && res_status <= 299
        print '.'
        "Success. Response status in the 2xx range. Response status: #{res_status}."
      else
        print 'F'
        "Failure. Response status NOT in the 2xx range. Response status: #{res_status}."
      end

    report[req] << log_entry
  end

  def log_type_mismatch(req, violator, actual_type, expected_type)
    log_entry = "TYPE MISMATCH\n" \
      "Expected type #{expected_type} for field \"#{violator}\", got #{actual_type}."

    report[req] ||= []
    report[req] << log_entry
  end

  def print_report
    print "\n\nFinished running the generated tests. Printing report...\n\n"
    print "REPORT\n\n"
    report.each do |req, log_entries|
      print "---------\n\n"
      print "REQUEST: #{req.uri.to_s}\n\n"
      log_entries.each_with_index do |log_entry, index|
        if index == 0
          print "OVERALL RESULTS: #{log_entry}\n\n"
          print "OTHER FINDINGS:\n\n"
        else
          print "#{log_entry}\n\n"
        end
      end
    end
    nil
  end
end
