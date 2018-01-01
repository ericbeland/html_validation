require 'open3'
require File.join(File.dirname(__FILE__), '..', 'html_validation')


class HTMLValidationResult
  attr_accessor :resource, :html, :exceptions, :options

  include PageValidations

  # :resource: a label (could be a url) representing the html in question
  # :html: the actual html
  # :datapath: where to find results
  # :options:

  # options ex: options[:tidy_opts] = ['--show-warnings false']
  def initialize(resource, html, datapath, tidy_flags = [], options = {})
    @resource = resource
    @html = html
    @exceptions = ''
    @datapath = datapath
    @tidy_flags = (HTMLValidation.default_tidy_flags + tidy_flags).uniq
    @options = options
    valid?
  end

  # An array of strings representing the default command line flags to pass to Tidy.
  # ex: ['--qi', '--show-warnings false']
  #
  # For a list of options (including how to pass a config file flag), see here:
  # http://w3c.github.com/tidy-html5/


  # takes a .url and loads the data into this object
  def self.load_from_files(filepath)
    resource = File.open("#{filepath}.resource.txt", 'r').read
    html = File.open("#{filepath}.html.txt", 'r').read
    HTMLValidationResult.new(resource, html, filepath)
  end

  # Validates an html string using html tidy. If there are no warnings or exceptions, or
  # there is a previously accepted exception string that matches exactly, valid? returns true
  # Line numbers of exceptions are likely to change with any edit, so our validation
  # compares the exception strings with the lines and columns removed. Name can be a filename,
  # file system path, or url, so long it is uniquely associated with the passed in html.
  def valid?
    @exceptions = validate
    File.delete(data_path("accepted")) if File.exists?(data_path("accepted")) if @exceptions == ''
    valid = (filter(@exceptions) == '' or accepted?(@exceptions))
    save_html_and_exceptions
    valid
  end

  # Saves the exception string for the given url or file path. When next run, if the exception
  # string is identical, valid? will return true. Note that #exceptions will still list the
  # exception string, though, even if it is an accepted exception string.
  def accept!
    File.open(data_path("accepted"), 'w') {|f| f.write(@exceptions)}
  end

  def reject!
    if File.exists?(data_path("accepted"))
      File.delete data_path("accepted")
    end
  end

  private
  # We used to specifically prefer /usr/bin/tidy by default on *nix as there is another "tidy" program
  # that could end up earlier on the path. Tidy was installed at this location for me by default.
  # The norm is now to custom install the tidy fork for HTML 5, though, and respecting the PATH is
  # better philosophically. Now we expect the PATH to be correct. ie,
  # if which Tidy being used is an issue, put the right tidy first on the PATH.
  def tidy_command
    is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
    bin = is_windows ? 'tidy.exe' : 'tidy'
    cmd = "#{bin} #{@tidy_flags.join(' ')}"
    cmd
  end

  # get the filename for storing a type of data
  def data_path(filetype)
    "#{@datapath}.#{filetype}.txt"
  end

  def save_html_and_exceptions
    File.open(data_path("html"), 'w') {|f| f.write(@html)}
    File.open(data_path("resource"), 'w') {|f| f.write(@resource)}
    File.open(data_path("exceptions"), 'w') {|f| f.write(@exceptions)}
  end

  # have we previously accepted this exact string for this path?
  def accepted?(exception_str)
    exception_str = filter(exception_str)
    File.exists?(data_path('accepted')) ? filter(File.open(data_path('accepted'), "r").read) == exception_str : false
  end

  # Line numbers of exceptions are likely to change with any minor edit, so our validation
  # compares the result strings with the lines and columns removed. This means that
  # if the errors change position in the file (up or down b/c you add or remove code),
  # accepted exception strings will remain valid.
  def filter(str)
    str = str.gsub(/^line.*trimming empty.*\n/, '') # the messages about empty are overzealous, and not invalid
    str = str.gsub(/^line.*proprietary.*\n/, '') if options[:ignore_proprietary] # if you use IE only attributes like wrap, or spellcheck or things not in standard
    str = str.gsub(/^line.*(?:Error|Warning):.*<\/?(?:#{options[:ignored_tag_errors].join('|')})>.*\n/, '') if options[:ignored_tag_errors] && options[:ignored_tag_errors].any?
    str = str.gsub(/^line.*(?:Error|Warning):.* attribute \"(?:#{options[:ignored_attribute_errors].join('|')})\".*\n/, '') if options[:ignored_attribute_errors] && options[:ignored_attribute_errors].any?
    if options[:ignored_errors] && options[:ignored_errors].any? && str.gsub(/^line.*(?:Error|Warning):/, '') =~ ignored_errors_regex
      str = str.gsub(Regexp.new(/^line.*(?:Error|Warning):/.source + '.*' + ignored_errors_regex.source + '.*' + /\n/.source), '')
    end
    str.gsub(/line [0-9]+ column [0-9]+ -/, '')
    # /line [0-9]+ column [0-9]+ - / +  =~ "line 1 column 1 - Warning: missing <!DOCTYPE> declaration"
  end

  def ignored_errors_regex
    /(?:#{options[:ignored_errors].join('|')})/
  end

  def validate
    stdin, stdout, stderr = Open3.popen3(tidy_command)
    stdin.puts @html.encode!("UTF-8", invalid: :replace, undef: :replace).force_encoding("utf-8")
    stdin.close
    stdout.close
    result = stderr.read
    stderr.close
    result
  end

end
