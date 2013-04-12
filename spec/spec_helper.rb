$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'html_validation'

include PageValidations

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/helpers/**/*.rb"].each {|f| require f }
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|


end

  def bad_html
    '<html><title>the title<title></head><body><p>blah blah</body></html>'
  end

  def good_html
    html_5_doctype + '<html><title>the title</title></head><body><p>a paragraph</p></body></html>'
  end

  def dtd
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  end

  def html_5_doctype
    '<!DOCTYPE html>'
  end

  def warning_html
    html_5_doctype + '<html><title proprietary="1">h</title></head><body><p>a para</p></body></html>'
  end