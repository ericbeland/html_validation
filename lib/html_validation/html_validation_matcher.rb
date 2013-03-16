# the item to include to get the RSPec matcher(s)

require File.expand_path(File.join(File.dirname(__FILE__),  'have_valid_html'))

module HTMLValidationMatcher
  @@data_path = nil  
  
  def self.included(base)
    # get path of including file, which should be in the /spec folder
    @@data_path, = File.expand_path(File.dirname(caller[0].partition(":")[0]))      
  end

  def self.data_path
    @@data_path
  end    
  
  def self.data_path=(path)
    @@data_path = path
  end
  
end