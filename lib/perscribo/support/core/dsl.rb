require 'perscribo/core/common'

module Perscribo
  module Support
    module Core
      module Dsl
        module ModuleRefinements
          refine(Module) do
            def publish!(*names)
              names.each do |m|
                module_function(m)
                public(m)
              end
            end
          end
        end

        module Bootstrappable
          using ModuleRefinements

          def self.included(base)
            base.extend(MethodMissingHook)
            base.publish!(:bootstrap!)
          end

          # TODO: REFACTOR THIS EVENTUALLY!
          module MethodMissingHook
            def method_missing(method, *args, &block)
              matches = /^(?<target>\w+)_straps$/.match(method)
              target = "#{matches[:target].capitalize}Methods"
              return lambda { self.const_get(:Bootstraps, false).const_get(target, false) }.call
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
            base.include(module_straps)
            (module_straps.try(:instance_methods, false) || []).each do |m|
              base.publish!(m)
            end
            base.send(:prepend, prepend_straps)
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
      end
    end
  end
end
