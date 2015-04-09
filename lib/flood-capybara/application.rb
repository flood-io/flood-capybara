require 'rspec'
require 'rspec/core/formatters/json_formatter'

class FloodCapybara
  def initialize
    @steps = []
  end

  def run(args = {})
    config.instance_variable_set(:@reporter, reporter)
    reporter.register_listener(formatter, *notifications)

    tags = ['--tag', args[:tag]] if args[:tag]

    RSpec::Core::Runner.run(['spec', '--dry-run'] + tags)

    specs = formatter.output_hash

    logger.info "Flood specs: \n" +
      specs[:examples].collect {|spec| spec[:description]}.to_yaml

    specs = specs[:examples].collect {|spec| spec[:file_path]}

    specs.try(:uniq).try(:each) do |spec|
      ast = Parser::CurrentRuby.parse(File.read(spec))
      iterate(ast)
    end

    flood(args)
  end

  private

  def config
    @_config ||= RSpec.configuration
  end

  def formatter
    @_formatter ||= RSpec::Core::Formatters::JsonFormatter.new(File.open(File::NULL, 'w'))
  end

  def reporter
    @_reporter ||= RSpec::Core::Reporter.new(config)
  end

  def loader
    @_loader ||= config.send(:formatter_loader)
  end

  def notifications
    @_notifications ||= loader.send(
      :notifications_for,
      RSpec::Core::Formatters::JsonFormatter)
  end

  def iterate(node)
    return unless node.is_a?(AST::Node)

    node.children.each_with_index do |child, index|
      begin
        if (child.to_a.first.children & [:it]).present?
          @steps << Unparser.unparse(child)
        end

        if (child.to_a.first.children & [:scenario]).present?
          @steps << Unparser.unparse(child)
        end
      rescue
      end
      iterate(child) if child.is_a?(AST::Node)
    end
  end

  def flood(args = {})
    RestClient.proxy = args[:proxy] if args[:proxy]

    response = RestClient.post endpoint(args), flood_params(args)

    if response.code == 201
      logger.info "Flood results: #{JSON.parse(response)["permalink"]}"
    else
      logger.fatal "Sorry there was an error: #{JSON.parse(response)["error"]}"
    end

    rescue => e
      logger.fatal "Sorry there was an error: #{JSON.parse(e.response)["error"]}"
  end

  def endpoint(args)
    "#{args[:endpoint] ? args[:endpoint] : 'https://api.flood.io'}/" +
      "floods?auth_token=#{args[:api_token]}"
  end

  def flood_params(args)
    {
      flood: {
        tool: 'capybara-rspec',
        url: args[:url],
        name: args[:name],
        notes: args[:notes],
        tag_list: args[:tag_list],
        threads: args[:threads],
        rampup: args[:rampup],
        duration: args[:duration],
        override_hosts: args[:override_hosts],
        override_parameters: args[:override_parameters],
        started: args[:started],
        stopped: args[:stopped],
        meta: git_info.to_json
      },
      flood_files: flood_files,
      region: args[:region],
      multipart: true,
      content_type: 'application/octet-stream'
    }.merge(args)
  end

  def git_info
    {
      sha: `git rev-parse HEAD`.chomp,
      repository: {
        full_name: `git rev-parse --abbrev-ref HEAD`.chomp,
        url: `git config --get remote.origin.url`.chomp
      }
    }
  end

  def flood_files
    {
      file: File.new("#{file.path}", 'rb')
    }
  end

  def file
    temp = Tempfile.new(['capybara_rspec', '.rb'])
    temp.write(@steps.join("\n"))
    temp.rewind
    temp
  end

  def logger
    @_log ||= Logger.new(STDOUT)
    @_log.level = Logger::DEBUG
    @_log
  end
end
