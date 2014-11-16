require 'rspec'
require 'rspec/core/formatters/json_formatter'

class FloodCapybara
  def initialize
    @steps = []
  end

  def run(params = {})
    logger.info "Minimizing maximums ..."
    config = RSpec.configuration
    formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)
    reporter =  RSpec::Core::Reporter.new(config)
    config.instance_variable_set(:@reporter, reporter)
    loader = config.send(:formatter_loader)
    notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)
    reporter.register_listener(formatter, *notifications)
    RSpec::Core::Runner.run(['spec', '--dry-run'])
    specs =  formatter.output_hash
    puts
    logger.warn "Found the following specs:\n" +
      specs[:examples].collect {|spec| spec[:description]}.join("\n")
    specs = specs[:examples].collect {|spec| spec[:file_path]}

    specs && specs.uniq.each do |spec|
      ast = Parser::CurrentRuby.parse(File.read(spec))
      iterate ast
    end
    flood params
  end

  private

  def iterate(node)
    return unless node.is_a?(AST::Node)

    node.children.each_with_index do |child, index|
      begin
        if child.to_a.first.children[1] == :it
          @steps << Unparser.unparse(child)
        end
      rescue
      end
      iterate(child) if child.is_a?(AST::Node)
    end
  end

  def flood(params={})
    RestClient.proxy = params[:proxy] if params[:proxy]
    begin
      file = Tempfile.new(['capybara_rspec', '.rb'])
      file.write(@steps.join("\n"))
      file.rewind

      flood_files = {
        file: File.new("#{file.path}", 'rb')
      }

      if params[:files]
        flood_files.merge!(Hash[params[:files].map.with_index { |value, index| [index, File.new(value, 'rb')] }])
        params.delete(:files)
      end

      response = RestClient.post "#{params[:endpoint] ? params[:endpoint] : 'https://api.flood.io'}/floods?auth_token=#{params[:api_token]}",
      {
        flood: {
          tool: 'capybara-rspec',
          url: params[:url],
          name: params[:name],
          notes: params[:notes],
          tag_list: params[:tag_list],
          threads: params[:threads],
          rampup: params[:rampup],
          duration: params[:duration],
          override_hosts: params[:override_hosts],
          override_parameters: params[:override_parameters],
          started: params[:started],
          stopped: params[:stopped]
        },
        flood_files: flood_files,
        region: params[:region],
        multipart: true,
        content_type: 'application/octet-stream'
      }.merge(params)

      if response.code == 200
        logger.info "Flood results at: #{JSON.parse(response)["response"]["results"]["link"]}"
      else
        logger.fatal "Sorry there was an error: #{JSON.parse(response)["error_description"]}"
      end
    rescue => e
      logger.fatal "Sorry there was an error: #{JSON.parse(e.response)["error_description"]}"
    end
  end

  def logger
    @log ||= Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    @log
  end
end
