require 'perscribo/format'

module Perscribo
  class Proxy
    DEFAULT_LINE_SPLITTER = proc do |text|
      text.split("\n").reject { |i| i.strip.empty? }.collapse!
    end

    def initialize(logger, &block)
      @logger, @interfaces, @bus = logger, {}, EventBus.new
      @line_splitter = block || DEFAULT_LINE_SPLITTER
    end

    def register(identifier, io_or_path, &block)
      block ||= @line_splitter
      @interfaces[identifier] = Watcher.new(io_or_path) do |lines|
        block.call(lines).each { |line| handle_line(identifier, line) }
      end
    end

    def listen(identifier, label, &block)
      @bus.on(identifier, label) do |*args|
        @logger.send(*block.call(*args))
      end
    end

    private

    def handle_line(identifier, line)
      label = (line = parse_line(line)).shift
      params = [line.flatten].unshift(identifier, label)
      @bus.trigger(identifier, label, *params)
    end

    def parse_line(line)
      captures = line.match(Perscribo::MATCH_REGEXP).try(:captures)
      args = captures || [:unknown, line]
      args.unshift(args.shift.to_sym)
    end
  end
end
