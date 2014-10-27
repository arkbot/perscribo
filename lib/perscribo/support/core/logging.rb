require 'perscribo/core/common'

require 'logger'
require 'singleton'

module Perscribo
  module Support
    module Core
      module Logging
        class ProxyLogger < ::Logger
          def initialize(*args)
            super
            self.formatter = ProxyLogger.method(:match_formatter).to_proc
          end

          def self.match_formatter(sev, datetime, progname, msg)
            s = ::Logger::Severity.constants.find { |i| i.to_s == sev.to_s }
            label = Constants::MATCH_FORMAT.gsub(':level', '%s') % s
            "#{label.downcase}#{msg}\n"
          end

          private_class_method :match_formatter
        end

        class MultiLogger < ProxyLogger
          attr_accessor :endpoints

          def initialize(*args)
            super
            @endpoints = []
          end

          def method_missing(m, *a, &b)
            self.class.superclass.instance_method(m).bind(self).call(*a, &b)
            endpoints.each { |i| i.try(m, *a, &b) }
          rescue NameError, NoMethodError
            super
          end
        end

        class SingletonLogger
          def self.instance(klazz = MultiLogger, root_path, name)
            root_path = File.expand_path(root_path)
            logdev = singleton_logfile(root_path, name)
            singleton_name(klazz, name).constantize.instance
          rescue NameError
            nesting, klazz_name = singleton_names(klazz, name)
            singleton = singleton_of(klazz, logdev)
            nesting.constantize.const_set(klazz_name, singleton).instance
          end

          class << self
            alias_method :[], :instance
          end

          def self.singleton_of(superklazz, logdev)
            Class.new(superklazz).inside do
              include Singleton
              const_set(:LOGDEV, logdev)
              def initialize(*args)
                io = self.class.const_get(:LOGDEV, false)
                super(io, *(args[1..-1] || []))
              end
            end
          end

          def self.singleton_names(klazz, name)
            path, name = klazz.to_s.split('::'), name.to_s.camelcase
            nesting = (path[0..-2] || [:Object]).join('::')
            node = "#{name}#{path.last}"
            [nesting, node]
          end

          def self.singleton_logfile(root_path, name)
            "#{root_path}/perscribo_#{name}_#{ENV['RACK_ENV']}.log"
          end

          SINGLETON_METHODS = methods(false).select do |i|
            i.to_s =~ /((.+)singleton(.+)?)/
          end

          private_class_method *SINGLETON_METHODS
        end
      end
    end
  end
end
