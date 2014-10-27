require 'perscribo/core/common'

module Perscribo
  module Core
    class Dispatcher
      def initialize
        @queues = {}
      end

      def on(queue, event, &block)
        @queues[queue] ||= {}
        @queues[queue][event] = block
      end

      # FIXME: This feels dirty. And it's not a FIFO queue.
      def trigger(queue, event, *args)
        @queues[queue][event].try(:call, *args)
      rescue
        # STUB
      end
    end
  end
end
