require 'active_support/core_ext/object/try'

module Perscribo
  class EventBus
    def initialize
      @queues = {}
    end

    def on(queue, event, &block)
      @queues[queue] ||= {}
      @queues[queue][event] = block
    end

    def trigger(queue, event, *args)
      @queues[queue][event].try(:call, *args)
    rescue
      # STUB
    end
  end
end
