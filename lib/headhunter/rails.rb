require 'headhunter'
require 'headhunter/rack/capturing_middleware'

if ENV['HEADHUNTER'] == 'true'
  class Headhunter
    module Rails
      class Railtie < ::Rails::Railtie
        initializer "headhunter.hijack" do |app|
          head_hunter = Headhunter.new(::Rails.root)

          at_exit do
            head_hunter.report
            head_hunter.clean_up!
          end

          app.middleware.insert(0, Headhunter::Rack::CapturingMiddleware, head_hunter)
        end
      end
    end
  end
end
