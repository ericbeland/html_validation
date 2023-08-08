require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HTMLValidation" do
  include HTMLValidationHelpers

  before(:each) do
    FileUtils.mkdir tmp_path if !File.exist?('/tmp/validation')
    @h = HTMLValidation.new('/tmp/validation')
  end

  it "returns false for invalid HTML" do
    expect(@h.validation(bad_html, "http://myothersite.com")).not_to be_valid
  end

  it "returns true for valid HTML" do
    expect(@h.validation(good_html, "http://mysite.com")).to be_valid
  end

  it "has an exception string for invalid HTML" do
    result = @h.validation(bad_html, "http://myfavoritesite.com")
    expect(result.exceptions).not_to be_empty
  end

  it "returns true for valid? if exceptions are accepted" do
    result = @h.validation(bad_html, "http://mynewsite.com")
    result.accept!
    expect(@h.validation(bad_html, "http://mynewsite.com")).to be_valid
  end

  it "shows no exceptions for a truly valid file" do
    result = @h.validation(good_html, "http://mybestsite.com")
    expect(result.exceptions).to be_empty
  end

  it "shows exceptions when returning valid for an accepted exception string" do
    result = @h.validation(bad_html, "http://myworstsite.com")
    result.accept!
    result = @h.validation(bad_html, "http://myworstsite.com")
    expect(result).to be_valid
    expect(result.exceptions).not_to be_empty
  end

  it "resets exceptions after each call to valid?" do
    result = @h.validation(bad_html, "http://myuglysite.com")
    result = @h.validation(good_html, "http://myuglysite.com")
    expect(result.exceptions).to be_empty
    expect(result).to be_valid
  end

  it "resets accepted exceptions string after seeing valid HTML for a path" do
    result = @h.validation(bad_html, "http://notmysite.com")
    result.accept!

    expect(@h.validation(bad_html, "http://notmysite.com")).to be_valid
    expect(@h.validation(good_html, "http://notmysite.com")).to be_valid
    expect(@h.validation(bad_html, "http://notmysite.com")).not_to be_valid
  end

  it "doesn't pass a different non-accepted exception" do
    result = @h.validation(bad_html, "http://mycoolsite.com")
    result.accept!
    expect(@h.validation("<html></body></html>", "http://mycoolsite.com")).not_to be_valid
  end

  it "ignores proprietary tags when ignore_proprietary is passed" do
    html_with_proprietary=good_html.gsub('<body>','<body><textarea wrap="true" spellcheck="true">hi</textarea>')
    result = @h.validation(html_with_proprietary, "http://mycrosoft.com")
    expect(result).not_to be_valid

    @h = HTMLValidation.new('/tmp/validation', [], :ignore_proprietary => true)
    result = @h.validation(html_with_proprietary, "http://mycrosoft.com")
    expect(result).to be_valid
  end

  it "works without a data path being manually set" do
    h = HTMLValidation.new
    result = h.validation(good_html, "http://mybestsite.com")
    expect(result.exceptions).to be_empty
  end

  it "respects warnings when they are turned off" do
    HTMLValidation.show_warnings = false
    h = HTMLValidation.new
    result = h.validation(warning_html, "http://mywarningsite.com")
    expect(result.exceptions).to be_empty

    HTMLValidation.show_warnings = true
    h = HTMLValidation.new
    result = h.validation(warning_html, "http://myotherwarningsite.com")
    expect(result.exceptions).to_not be_empty
  end

  it "respects ignored_attribute_errors" do
    HTMLValidation.ignored_attribute_errors = ["tabindex"]
    h = HTMLValidation.new
    result = h.validation(good_html.gsub('<body>','<body><span tabindex="-1">blabla</span>'), "http://mywarningsite.com")
    expect(result).to be_valid
    HTMLValidation.ignored_attribute_errors = []
  end

  it "respects ignored_tag_errors" do
    HTMLValidation.ignored_tag_errors = ['inline']
    h = HTMLValidation.new()
    result = h.validation(good_html.gsub('<body>','<body><inline>rrr</inline>'), "http://mywarningsite.com")
    expect(result).to be_valid
    HTMLValidation.ignored_tag_errors = []
  end

  it "respects ignored_errors" do
    HTMLValidation.ignored_errors = ['inline']
    h = HTMLValidation.new()
    result = h.validation(good_html.gsub('<body>','<body><inline>rrr</inline>'), "http://mywarningsite.com")
    expect(result).to be_valid
    HTMLValidation.ignored_errors = []
  end

  context "when launching HTML Tidy" do

    it "lets me pass different Tidy command line options" do
      @h = HTMLValidation.new('/tmp/validation')
      result = @h.validation("<html>foo", 'c:\mycoolapp\somesite.html')
      expect(result.exceptions).to include("Warning:")

      @h = HTMLValidation.new('/tmp/validation', ["--show-warnings false"])
      result = @h.validation("<html>foo", 'c:\mycoolapp\somesite.html')
      expect(result.exceptions).not_to include("Warning:")
    end

  end

  context "when walking exception results" do

    it "yields loaded exception results" do
      @h = HTMLValidation.new('/tmp/validation')
      result = @h.validation("<html>foo", 'c:\evencooler.com\somesite.html')
      had_exceptions = false
      @h.each_exception do |e|
        had_exceptions = true

        expect(e).to be_a(HTMLValidationResult)
        expect(e.resource).not_to be_empty
        expect(e.html).not_to be_empty
      end

      expect(had_exceptions).to be_truthy
    end

  end

end

