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



require File.expand_path(File.join(File.dirname(__FILE__),  'html_validation/page_validations'))
require File.expand_path(File.join(File.dirname(__FILE__),  'html_validation/html_validation_result'))
require File.expand_path(File.join(File.dirname(__FILE__),  'html_validation/html_validation_matcher'))
