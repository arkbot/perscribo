require 'perscribo/core/common'

module Perscribo
  module Support
    module Core
      module Dsl
        module Bootstrappable
          include Refinements

          def self.included(base)
            base.publish!(:bootstrap!)
            base.extend(MethodMissingHook)
          end

          # TODO: REFACTOR THIS EVENTUALLY!
          module MethodMissingHook
            def method_missing(method, *args, &block)
              matches = /^(?<target>\w+)_straps$/.match(method)
              target = "#{matches[:target].capitalize}Methods"
              return lambda do
                self.const_get(:Bootstraps, false).const_get(target, false)
              end.call
            rescue NameError
              lambda do
                const_set(:Bootstraps, Module.new) unless const_defined?(:Bootstraps, false)
                const_get(:Bootstraps, false).const_set(target, Module.new)
              end.call
            rescue
              super
            end
          end

          def bootstrap!(base)
            base.extend(class_straps)
            base.include(instance_straps)
            base.inside do
              include(module_straps)
              instance_methods(false).each(&method(:publish!))
              prepend(prepend_straps)
            end
            # (module_straps.try(:instance_methods, false) || []).each do |m|
            #   m.define_singleton_method(m, &module_straps.instance_method(m))
            # end
            # base.send(:prepend, prepend_straps)
          end
        end

        # module Lookup
        #   include Bootstrappable

        #   module Bootstraps
        #     module ClassMethods
        #       def const_missing(name)
        #         super
        #       rescue NameError
        #         find_constant(name)
        #       end

        #       def method_missing(method, *args, &block)
        #         super
        #       rescue NameError
        #         find_helper(method, *args, &block)
        #       end

        #       def find_children(base = self)
        #         base.constants.select { |i| base.const_get(i).is_a?(Module) }
        #       end

        #       # FIXME: STUB
        #       def find_constant(name)
        #         puts "find_constant(:#{name}) in #<Child:modules#{find_children.inspect}>"
        #       end

        #       # FIXME: STUB
        #       def find_helper(method, *args, &block)
        #         puts "find_helper(:#{method}) in #<Child:modules#{find_children.inspect}>"
        #       end
        #     end
        #   end
        # end

        module Refinements
          def self.included(base)
            base.send(:using, ModuleRefinements) if base.is_a?(Module)
          end

          module ModuleRefinements
            include refine(Module) do
              def publish!(*names)
                names.each do |m|
                  module_function(i)
                  public(i)
                end
              end
            end
          end
        end
      end
    end
  end
end
