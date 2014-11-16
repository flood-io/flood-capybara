require 'rspec'
require 'rspec/core/formatters/json_formatter'

class FloodCapybara
  def initialize
    @steps = []
  end

  def run(params = {})
    logger.info loading
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

  def loading
    ["Adding Hidden Agendas","Adjusting Bell Curves","Aesthesizing Industrial Areas","Aligning Covariance Matrices","Applying Feng Shui Shaders","Applying Theatre Soda Layer","Asserting Packed Exemplars","Attempting to Lock Back-Buffer","Binding Sapling Root System","Breeding Fauna","Building Data Trees","Bureacritizing Bureaucracies","Calculating Inverse Probability Matrices","Calculating Llama Expectoration Trajectory","Calibrating Blue Skies","Charging Ozone Layer","Coalescing Cloud Formations","Cohorting Exemplars","Collecting Meteor Particles","Compounding Inert Tessellations","Compressing Fish Files","Computing Optimal Bin Packing","Concatenating Sub-Contractors","Containing Existential Buffer","Debarking Ark Ramp","Debunching Unionized Commercial Services","Deciding What Message to Display Next","Decomposing Singular Values","Decrementing Tectonic Plates","Deleting Ferry Routes","Depixelating Inner Mountain Surface Back Faces","Depositing Slush Funds","Destabilizing Economic Indicators","Determining Width of Blast Fronts","Deunionizing Bulldozers","Dicing Models","Diluting Livestock Nutrition Variables","Downloading Satellite Terrain Data","Exposing Flash Variables to Streak System","Extracting Resources","Factoring Pay Scale","Fixing Election Outcome Matrix","Flood-Filling Ground Water","Flushing Pipe Network","Gathering Particle Sources","Generating Jobs","Gesticulating Mimes","Graphing Whale Migration","Hiding Willio Webnet Mask","Implementing Impeachment Routine","Increasing Accuracy of RCI Simulators","Increasing Magmafacation","Initializing My Sim Tracking Mechanism","Initializing Rhinoceros Breeding Timetable","Initializing Robotic Click-Path AI","Inserting Sublimated Messages","Integrating Curves","Integrating Illumination Form Factors","Integrating Population Graphs","Iterating Cellular Automata","Lecturing Errant Subsystems","Mixing Genetic Pool","Modeling Object Components","Mopping Occupant Leaks","Normalizing Power","Obfuscating Quigley Matrix","Overconstraining Dirty Industry Calculations","Partitioning City Grid Singularities","Perturbing Matrices","Pixalating Nude Patch","Polishing Water Highlights","Populating Lot Templates","Preparing Sprites for Random Walks","Prioritizing Landmarks","Projecting Law Enforcement Pastry Intake","Realigning Alternate Time Frames","Reconfiguring User Mental Processes","Relaxing Splines","Removing Road Network Speed Bumps","Removing Texture Gradients","Removing Vehicle Avoidance Behavior","Resolving GUID Conflict","Reticulating Splines","Retracting Phong Shader","Retrieving from Back Store","Reverse Engineering Image Consultant","Routing Neural Network Infanstructure","Scattering Rhino Food Sources","Scrubbing Terrain","Searching for Llamas","Seeding Architecture Simulation Parameters","Sequencing Particles","Setting Advisor Moods","Setting Inner Deity Indicators","Setting Universal Physical Constants","Sonically Enhancing Occupant-Free Timber","Speculating Stock Market Indices","Splatting Transforms","Stratifying Ground Layers","Sub-Sampling Water Data","Synthesizing Gravity","Synthesizing Wavelets","Time-Compressing Simulator Clock","Unable to Reveal Current Activity","Weathering Buildings","Zeroing Crime Network"].sample
  end
end
