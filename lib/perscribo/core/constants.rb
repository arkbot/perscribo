module Perscribo
  module Core
    unless const_defined?(:Constants, false)
      module Constants
        MATCH_FORMAT = '[<![ :level ]!>] '
        MATCH_REGEXP = /\[\<\!\[ (\w+) \]\!\>\] (.*)/m
      end
    end
  end
end
