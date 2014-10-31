require 'perscribo/core/common'

require 'logger'
require 'singleton'

module Perscribo
  module Support
    module Core
      module Logging
        class EndpointLogger < ::Logger
          attr_accessor :endpoints

          def initialize(*endpoints)
            super('/dev/null')
            @endpoints = endpoints
            self.class.redirect_class_methods(self)
            self.class.redirect_instance_methods(self)
          end

          def self.redirect_class_methods(this)
            this.class.superclass.methods(false).each do |name|
              this.class.define_method(name) do |*args, &block|
                method_missing(name, *args, &block)
              end
            end
          end

          def self.redirect_instance_methods(this)
            this.class.superclass.instance_methods(false).each do |name|
              this.define_singleton_method(name) do |*args, &block|
                method_missing(name, *args, &block)
              end
            end
          end

          def respond_to?(*args)
            endpoints.collect { |i| i.respond_to?(*args) }.all?
          end

          def method_missing(m, *a, &b)
            endpoints.collect { |i| i.try(m, *a, &b) }.last
          rescue NameError, NoMethodError
            super
          end
        end

        class ProxyLogger < ::Logger
          def initialize(*args)
            super
            self.formatter = ProxyLogger.method(:match_formatter).to_proc
          end

          def self.match_formatter(sev, datetime, progname, msg)
            s = ::Logger::Severity.constants.find { |i| i.to_s == sev.to_s }
            label_format = ::Perscribo::Core::Constants::MATCH_FORMAT
            label = label_format.gsub(':level', '%s') % s
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
          def self.instance(klazz = ProxyLogger, root_path, name)
            root_path = File.expand_path(root_path)
            logdev = singleton_logfile(root_path, name)
            singleton_name(klazz, name).constantize.instance
          rescue NameError
            nesting, klazz_name = singleton_names(klazz, name)
            singleton = singleton_of(klazz, logdev)
            const_of(nesting, klazz_name, singleton).instance
          end

          class << self
            alias_method :[], :instance
          end

          def self.const_of(parent, const_name, const_value)
            parent.constantize.const_get(const_name, false)
          rescue NameError
            parent.constantize.const_set(const_name, const_value)
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
