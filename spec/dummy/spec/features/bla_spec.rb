require 'spec_helper'

feature 'Middleware integration' do
  scenario "Integrating the middleware into the Rack stack" do
    expect(Headhunter::Rack::CapturingMiddleware.any_instance).to receive(:call)
    visit posts_path
  end
end
