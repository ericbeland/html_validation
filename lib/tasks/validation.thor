#!/usr/bin/env thor
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'html_validation'))

class Acceptance < Thor
  desc "review", "Review and Accept (or fix and rerun) HTML Validation errors"
  
  method_option :data_path, :aliases => "-d", :desc => "Optional custom data path (if not default of /spec/.validate)"
  def review
    data_path  = options[:data_path] || File.join(Dir.getwd, 'spec', '.validation')
    $stdout.puts "Reviewing acceptance results in: #{data_path}"
  
    ::HTMLValidation.new(data_path).each_exception do |result|
      $stdout.puts "Validation exceptions for: #{result.resource}:\n#{result.exceptions}" 
      $stdout.puts "Accept (y)es (n)o or (q)uit"
      sin=$stdin.gets
      if sin[0].downcase == 'y'
        result.accept! 
        $stdout.puts "Accepted!"
      else
        $stdout.puts "Rejected!"
      end
      exit if sin.downcase == 'exit' or sin.downcase == 'quit' or sin.downcase == 'q'
    end
    $stdout.puts "HTML Validation Acceptance completed"
  end
end