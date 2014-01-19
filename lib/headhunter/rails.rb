require 'headhunter'
require 'headhunter/rack/capturing_middleware'

class Headhunter
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "headhunter.hijack" do |app|
        root = ::Rails.root

        head_hunter = Headhunter.new
        at_exit { head_hunter.report }

        app.middleware.insert(0, Headhunter::Rack::CapturingMiddleware, head_hunter)
      end
    end
  end
end
