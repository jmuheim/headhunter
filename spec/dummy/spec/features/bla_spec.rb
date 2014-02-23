require 'spec_helper'

feature 'Middleware integration' do
  scenario "Integrating the middleware into the Rack stack" do
    Headhunter::Rack::CapturingMiddleware.any_instance.should_receive(:call)
    visit posts_path
  end
end
