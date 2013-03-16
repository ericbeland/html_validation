require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


  
describe "HTMLValidation" do
  
  before(:each) do
    FileUtils.mkdir tmp_path if !File.exists?('/tmp/validation')
    @h = HTMLValidation.new('/tmp/validation')    
  end
  
  it "should return false for invalid xml" do
    result = @h.validation(bad_html, "http://myothersite.com").valid?.should be_false
  end
  
  it "should return true for valid html" do
    result = @h.validation(good_html, "http://mysite.com").valid?.should be_true
  end
  
  it "should have an exception string for invalid xml" do
    result = @h.validation(bad_html, "http://myfavoritesite.com")
    (result.exceptions.empty?).should be_false
  end
  
  it "should return true for valid? if exceptions are accepted" do
    result = @h.validation(bad_html, "http://mynewsite.com")
    result.accept!
    result = @h.validation(bad_html, "http://mynewsite.com").valid?.should be_true
  end
  
  it "should show no exceptions for a truly valid file" do
    result = @h.validation(good_html, "http://mybestsite.com")
    (result.exceptions == '').should be_true
  end
  
  it "should still show exceptions when returning valid for an accepted exception string" do
    result = @h.validation(bad_html, "http://myworstsite.com")
    result.accept!
    result = @h.validation(bad_html, "http://myworstsite.com")
    result.valid?.should be_true
    (result.exceptions.length == 0).should be_false
  end
  
  it "should reset exceptions after each call to valid?" do
    result = @h.validation(bad_html, "http://myuglysite.com")
    result = @h.validation(good_html, "http://myuglysite.com")
    (result.exceptions.length == 0).should be_true
    result.valid?.should be_true
  end
  
  it "should reset accepted exceptions string after seeing valid html for a path" do
    result = @h.validation(bad_html, "http://notmysite.com")
    result.accept!
    result = @h.validation(bad_html, "http://notmysite.com").valid?.should be_true
    # now we see valid, so we should reset
    result = @h.validation(good_html, "http://notmysite.com").valid?.should be_true
    result = @h.validation(bad_html, "http://notmysite.com").valid?.should be_false
  end
  
  it "should not pass a different non-accepted exception" do
    result = @h.validation(bad_html, "http://mycoolsite.com")
    result.accept!
    result = @h.validation("<html></body></html>", "http://mycoolsite.com").valid?.should be_false    
  end
  
  it "should ignore proprietary tags when ignore_proprietary is passed" do
	  html_with_proprietary=good_html.gsub('<body>','<body><textarea wrap="true" spellcheck="true">hi</textarea>')	
	  result = @h.validation(html_with_proprietary, "http://mycrosoft.com")
	  result.valid?.should be_false		
	  @h = HTMLValidation.new('/tmp/validation', :ignore_proprietary=>true)
	  result = @h.validation(html_with_proprietary, "http://mycrosoft.com")
	  result.valid?.should be_true
  end
  
  it "should work without a data path being manually set" do
     h = HTMLValidation.new()    
     result = h.validation(good_html, "http://mybestsite.com")
    (result.exceptions == '').should be_true        
  end
  
  
  describe "when launching HTML Tidy" do
    
    it "should let me pass different Tidy command line options" do
      @h = HTMLValidation.new('/tmp/validation', :tidy_opts=>"-e")
      result = @h.validation("<html>foo", 'c:\mycoolapp\somesite.html')
      result.exceptions.include?("were found!").should be_true
      @h = HTMLValidation.new('/tmp/validation')
      result = @h.validation("<html>foo", 'c:\mycoolapp\somesite.html')
      result.exceptions.include?("were found!").should be_false  
	  end
    
  end
  
  describe "when walking exception results" do
  
    it "should yield loaded exception results" do	
      @h = HTMLValidation.new('/tmp/validation')
      result = @h.validation("<html>foo", 'c:\evencooler.com\somesite.html')  
      had_exceptions = false
      @h.each_exception do |e|
        had_exceptions = true
          e.is_a?(HTMLValidationResult).should be_true
          (e.resource.length > 0).should be_true
          (e.html.length > 0).should be_true
        end	
      had_exceptions.should be_true
	  end
 
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