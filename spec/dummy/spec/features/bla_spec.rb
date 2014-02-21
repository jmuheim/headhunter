require 'spec_helper'

feature 'Info center' do
  background do
    # Bla...
  end

  scenario "Showing the list's column names: Wo?, Wer?, Was? and Wann?" do
    visit posts_path

    expect(page).to have_content 'Listing posts'
  end
end
