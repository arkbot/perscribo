require 'perscribo/core/common'

module Perscribo
  class Watcher
    def initialize(io_or_path, options = {}, &block)
      @io, @options, @block = io_or_path, parse_options(options), block
      @pid = watch(@io, &@block)
      at_exit { close }
    end

    def close
      Process.kill(9, @pid)
    end

    private

    def watch(io_or_path, &block)
      File.open(io_or_path, 'w') {} if io_or_path.is_a?(String)
      fork do
        open(io_or_path, 'r') do |io|
          io.seek(0, ::IO::SEEK_END)
          tail(io, &block)
        end
      end
    end

    def tail(io, &block)
      update_timestamp(io)
      update_position(0, ::IO::SEEK_END)
      loop do
        delegate_read(io, &block)
        sleep 0.1
      end
    end

    def delegate_read(io, &block)
      rewind_on_touch?(io)
      forward_read(io).inside { block.call(self) unless empty? }
      truncate_on_read?(io)
    end

    def forward_read(io)
      set_cursor(io)
      lines = (io.read || '')
      update_position(io)
      lines
    end

    def set_cursor(io)
      io.seek(*@cursor)
    end

    def update_position(*args)
      @cursor = args.size == 2 ? args : [args.first.pos || 0, ::IO::SEEK_SET]
    end

    def parse_options(options = nil)
      options ||= {}
      options[:rewind_on_touch] ||= true
      options[:truncate_on_read] ||= false
      options
    end

    def rewind_on_touch?(io)
      return unless @options[:rewind_on_touch]
      return unless @last_time < io.mtime
      io.rewind
      update_timestamp(io)
    end

    def truncate_on_read?(io)
      return unless @options[:truncate_on_read]
      return unless @last_time < io.mtime
      File.truncate(io, 0)
      update_timestamp(io)
    end

    def update_timestamp(io)
      @last_time = @last_time.nil? ? io.stat.atime : io.mtime
    end
  end
end
