$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'html_validation'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/helpers/**/*.rb"].each {|f| require f }

include PageValidations
include HTMLValidationHelpers

RSpec.configure do |config|


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

