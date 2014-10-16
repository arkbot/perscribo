require 'logger'
require 'perscribo/format'

module Perscribo
  class Logger < ::Logger
    def initialize(*args)
      super(*args)
      self.formatter = proc do |severity, datetime, progname, msg|
        severity_name = ::Logger::Severity::constants.find { |i| i.to_s == severity.to_s }
        label = Perscribo::MATCH_FORMAT.gsub(':label', '%s') % severity_name
        "#{label.downcase}#{msg}\n"
      end
    end
  end
end
