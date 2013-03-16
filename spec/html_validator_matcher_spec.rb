require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'html_validation/have_valid_html'

describe "HTMLValidationRSpecMatcher" do
    
  before(:each) do
     @page = double("page")
  end

  it "should check page object with the matcher for valid HTML and pass valid html" do
    @page.stub :html => good_html
    @page.stub :body => good_html
    @page.stub :current_url => 'http://www.fake.com/good_page'
    @page.should have_valid_html
  end
  
   it "should check page object with the matcher for valid HTML and fail bad HTML" do
    @page.stub :html => bad_html
    @page.stub :body => bad_html
    @page.stub :current_url => 'http://www.fake.com/bad_page'
    @page.should_not have_valid_html
  end
  
  
  private

  def bad_html
    '<html><title>the title<title></head><body><p>blah blah</body></html>'
  end
  
  def good_html
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><title>the title</title></head><body><p>a paragraph</p></body></html>'
  end
    
  def tmp_path
    is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
    is_windows ? 'c:\temp\validation' : '/tmp/validation'
  end
  
  # clean our temp dir without killing it
  def clean_dir(dir)
    Dir.chdir(dir)
    Dir.glob('*').each {|f| FileUtils.rm f }
  end
  
end