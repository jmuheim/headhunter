require 'spec_helper'

feature 'Middleware integration' do
  scenario "Integrating the middleware into the Rack stack" do
    pending "The expectation doesn't work, see http://stackoverflow.com/questions/21940082"
    Headhunter::Rack::CapturingMiddleware.any_instance.should_receive(:call)
    visit posts_path
  end
end
