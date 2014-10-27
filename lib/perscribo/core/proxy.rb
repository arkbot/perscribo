require 'perscribo/core/common'
require 'perscribo/core/dispatcher'

module Perscribo
  module Core
    class Proxy
      DEFAULT_LINE_SPLITTER = proc do |text|
        Proxy.collapse_lines!(text.split("\n").reject { |i| i.strip.empty? })
      end

      def initialize(logger, &block)
        @logger, @interfaces, @bus = logger, {}, Dispatcher.new
        @line_splitter = block || DEFAULT_LINE_SPLITTER
      end

      def register(*args, &block)
        if args.size == 1
          return register_config(args.first, &block) if args.first.is_a?(Hash)
        end
        register_params(*args, &block)
      end

      def listen(identifier, *labels, &block)
        labels.each do |label|
          @bus.on(identifier, label) do |*args|
            @logger.send(*block.call(*args))
          end
        end
      end

      def self.collapse_lines!(lines, *collapsables)
        lines.each_index do |i|
          prev, curr = lines[i - 1], lines[i]
          next if collapsables.any? && collapsables.exclude?(lines[i])
          lines.delete_at(i) if i > 0 && prev == curr
        end
      end

      private

      def register_config(config, &block)
        params = [
          config[:identifier],
          config[:path],
          config[:watcher_opts]
        ]
        register_params(*params, &(config[:splitter_block] || block))
      end

      def register_params(identifier, io_or_path, watcher_opts = {}, &block)
        block ||= @line_splitter
        @interfaces[identifier] = Watcher.new(io_or_path, watcher_opts) do |lines|
          block.call(lines).each { |line| handle_line(identifier, line) }
        end
      end

      def handle_line(identifier, line)
        label = (line = parse_line(line)).shift
        params = [line.flatten].unshift(identifier, label)
        @bus.trigger(identifier, label, *params)
      end

      def parse_line(line)
        regexp = Constants::MATCH_REGEXP
        captures = line.match(regexp).try(:captures)
        args = captures || [:unknown, line]
        args.unshift(args.shift.to_sym)
      end
    end
  end
end
