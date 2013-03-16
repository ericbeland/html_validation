require 'html_validation'

# This is a sample matcher for use with Rspec and Capybara. 
# https://github.com/jnicklas/capybara 
# keep this in spec/support/matchers
module PageValidations
  
  class HaveValidHTML
 
    # This is the matching method called by RSpec
    # The response is passed in as an argument when you do this:
    # page.should have_valid_html
  
    @@show_html_in_failures = false
 
    def self.show_html_in_failures=(val)
      @@show_html_in_failures = val
    end
  
    def matches?(page)
      h  = HTMLValidation.new
      @v = h.validation(page.body, page.current_url)
      @v.valid?
    end
  
    def description
      "Have valid html"
    end

    def failure_message_for_should
      "#{@v.resource} Invalid html (fix or run rake html_validation task to add exceptions)\n#{@v.resource} exceptions:\n #{@v.exceptions}\n\n #{@v.html if @@show_html_in_failures}"
    end
  
    def failure_message_for_should_not
      "#{@v.resource} Expected valid? to fail but didn't. Did you accidentally accept these html validation errors?  \n#{@v.resource} exceptions:\n #{@v.exceptions}\n\n #{@v.html if @@show_html_in_failures}"
    end  
  
  end

  def have_valid_html
    HaveValidHTML.new
  end

end