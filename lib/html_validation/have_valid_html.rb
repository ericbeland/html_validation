module PageValidations

  class HaveValidHTML

    # This is the matching method called by RSpec
    # The response is passed in as an argument when you do this:
    # page.should have_valid_html

    @@html_in_failures = false

    def self.show_html_in_failures=(val)
      @@html_in_failures = val
    end

    def matches?(page)
      h  = HTMLValidation.new
      @v = h.validation(page.body, page.current_url)
      @v.valid?
    end

    def description
      "have valid HTML"
    end

    def failure_message_for_should
      "#{@v.resource} Invalid html (fix or run 'html_validation review' to add exceptions)\n#{@v.resource} exceptions:\n #{@v.exceptions}\n\n #{@v.html if @@html_in_failures}"
    end
    alias :failure_message :failure_message_for_should

    def failure_message_for_should_not
      "#{@v.resource} Expected valid? to fail but didn't. Did you accidentally accept these validation errors?  \n#{@v.resource} exceptions:\n #{@v.exceptions}\n\n #{@v.html if @@html_in_failures}"
    end
    alias :failure_message_when_negated :failure_message_for_should_not

  end

  def have_valid_html
    HaveValidHTML.new
  end

end
