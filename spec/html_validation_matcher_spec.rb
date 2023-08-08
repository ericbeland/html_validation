require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'html_validation/have_valid_html'

describe "HTMLValidationRSpecMatcher" do
  include HTMLValidationHelpers

  before(:each) do
     @page = double("page")
  end

  it "checks page object with the matcher for valid HTML and pass valid HTML" do
    allow(@page).to receive(:html).and_return(good_html)
    allow(@page).to receive(:body).and_return(good_html)
    allow(@page).to receive(:current_url).and_return('http://www.fake.com/good_page')

    expect(@page).to have_valid_html
  end

   it "checks page object with the matcher for valid HTML and fail bad HTML" do
    allow(@page).to receive(:html).and_return(bad_html)
    allow(@page).to receive(:body).and_return(bad_html)
    allow(@page).to receive(:current_url).and_return('http://www.fake.com/bad_page')

    expect(@page).to_not have_valid_html
  end
end
