# == HTML Validation
# HTLM Acceptance helps you watch and come to terms with your HTML's validity, or lack thereof.  
# The idea is to take an html markup string associated with a particular path (file or URL),
# and validate it. It is intended to be used in acceptance tests, test suites or a rake task
# to alert you to changes in your html's validity so you can fix them, or barring that, review and accept
# errors and warnings. 

# ==Resource paths
# When calling the validation routine, a path, or URL is passed. This is used internally to name 
# the resulting validation output files.

# NOTE: HTMLValidation never retreives html or reads in files *for* you. It doesn't read files, or call 
# passed URL's. The purpose of passing a resource path is to give the test a name which saved exceptions 
# can be stored against and compared to. In theory, the resource could be any distinct string, meaningful or not.

# If the resource (URL or file) has a saved exception string and it matches, the validation passes. 
# The user can use a rake task can run this manually and upd  ate the accepted exception string.

require 'rbconfig'

require File.expand_path(File.join(File.dirname(__FILE__),  'html_validation/html_validation_result'))
require File.expand_path(File.join(File.dirname(__FILE__),  'html_validation/html_validation_matcher'))

module PageValidations
  
  class HTMLValidation
    
    # The data_folder is where we store our output. options[:tidyopts], which defaults to "-qi"
    # can be used to override the command line options to html tidy.  On *nix, man tidy to see
    # what else you might use for this string instead of "-qi", however "-qi" is probably what 
    # you want 95% of the time.
  
    # You may also pass :ignore_proprietary => true as an option to suppress messages like: 
    #  line 1 column 176 - Warning: <textarea> proprietary attribute "wrap"
    #  line 1 column 176 - Warning: <textarea> proprietary attribute "spellcheck"
  
    # It may be useful to pass a subfolder in your project as the data_folder, so your
    # HTML Validation status and validation results are stored along with your source. 
    def initialize(folder_for_data = nil, options = {})
      self.data_folder = folder_for_data || default_result_file_path
      @options         = options
    end

    # For each stored exception, yield an HTMLValidationResult object to allow the user to 
    # call .accept! on the exception if it is OK.  
    def each_exception
      Dir.chdir(@data_folder)
      Dir.glob("*.exceptions.txt").each do |file|
        if File.open(File.join(@data_folder, file), 'r').read != ''
          yield HTMLValidationResult.load_from_files(file.gsub('.exceptions.txt',''))
        end
      end
    end
  
    def validation(html, resource)
      resource_data_path = File.join(@data_folder, filenameize(resource))
      HTMLValidationResult.new(resource, html, resource_data_path, @options)
    end
  
    def data_folder=(path)
      FileUtils.mkdir_p(path)   
      @data_folder = path                          
    end
  
    def default_result_file_path
      posix = RbConfig::CONFIG['host_os'] =~ /(darwin|linux)/
      rootpath = Rails.root if defined?(Rails)
      rootpath ||= HTMLValidationMatcher.data_path if HTMLValidationMatcher.data_path    
      rootpath ||= posix ? '/tmp/' : "c:\\tmp\\"
      File.join(rootpath, '.validation')
    end
  
    private
  
    # Takes a url or filepath qne trims and sanitizes it for use as a filename.
    def filenameize(path)
      path.gsub!(/www.|^(http:\/\/|\/|C:\\)/, '')
      path.gsub(/[^0-9A-Za-z.]/, '_')  
    end
  
  end
end
