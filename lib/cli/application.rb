require 'thor'

module FloodCapybara
  module Capybara
    module Cli
      class Application < Thor

        desc 'hello NAME', 'Display greeting with given NAME'
        def hello(name)
          puts "Hello #{name}"
        end
      end
    end
  end
end
