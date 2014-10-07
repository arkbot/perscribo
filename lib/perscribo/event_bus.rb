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
      @queues.try(queue).try(event).try(:call, *args)
    end
  end
end
