require 'thor'

class FloodCapybara
  module Cli
    class Application < Thor

      desc 'spec', 'run specs on Flood IO'
      option :api_token
      option :grid_id
      option :rampup
      option :duration
      option :name
      option :url
      def spec
        specs = FloodCapybara.new
        specs.run options
      end
    end
  end
end
