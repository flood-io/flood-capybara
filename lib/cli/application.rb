require 'thor'

class FloodCapybara
  module Cli
    class Application < Thor

      desc 'spec API_TOKEN', 'run specs on Flood IO'
      option :grid_id
      def spec(api_token)
        specs = FloodCapybara.new
        specs.run api_token, options
      end
    end
  end
end
