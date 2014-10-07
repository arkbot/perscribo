$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'guard-perscribo'

require 'perscribo-cucumber/support/guard_helper'
require 'perscribo-rspec/support/guard_helper'
require 'perscribo-rubocop/support/guard_helper'

group :red_green_refactor, halt_on_fail: true do
  guard :shell, notification: true do
    watch(%r{^Rakefile|(?:(?:test|lib)/support/|main)(.+)\.rb}) do
      begin
        reload_guardfile
      rescue
        puts 'WARNING: the `guard-perscribo` gem is not installed.'
      end
    end
  end

  guard :cucumber, (CUKE_OPTS = DEFAULT_CUKE_OPTS) do
    watch(%r{^test/features/.+\.feature$})
    watch(%r{^test/features/(?:support|step_definitions)/(.+)(?:_steps)\.rb$}) do |m|
      Dir[File.join("**/#{m[1]}.feature")][0] || CUKE_OPTS[:feature_sets]
    end
  end

  guard :rspec, (RSPEC_OPTS = DEFAULT_RSPEC_OPTS) do
    watch(%r{^test/support/spec_helper\.rb}) { "test/spec" }
    watch(%r{^test/spec/(.+)\.rb}) { |m| "#{m[0]}" }
    watch(%r{^lib/(.+)\.rb}) { |m| "test/spec/lib/#{m[1]}_spec.rb" }
  end

  guard :rubocop, (RUBOCOP_OPTS = DEFAULT_RUBOCOP_OPTS) do
    watch(%r{^.rubocop.yml$}) { '.' }
    watch(%r{^Guardfile|Rakefile|(.+)\.rb$}) { |m| "#{m[0]}" }
  end
end
