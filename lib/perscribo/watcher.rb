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
      File.touch(io_or_path) if io_or_path.is_a?(String)
      fork do
        open(io_or_path, 'r') do |io|
          io.seek(0, ::IO::SEEK_END)
          # return tail_kqueue(io, &block) if RUBY_PLATFORM =~ /bsd|darwin/
          # return tail_inotify(io, &block) if RUBY_PLATFORM =~ /linux/
          tail_normal(io, &block)
        end
      end
    end

    # def tail_kqueue(io, &block)
    #   require 'rb-kqueue'
    #   KQueue::Queue.new.instance_exec(io, block) do |io, block|
    #     watch_file(io, :extend) { block.call(io.read) }
    #     run
    #   end
    # end

    # def tail_inotify(io, &block)
    #   require 'rb-inotify'
    #   INotify::Notifier.new.instance_exec(io, block) do |io, block|
    #     watch(io, :modify) { block.call(io.read) }
    #     run
    #   end
    # end

    def tail_normal(io, &block)
      update_timestamp(io)
      loop do
        rewind_on_touch?(io)
        lines = io.read
        block.call(lines) unless lines.empty?
        sleep 0.1
      end
    end

    def parse_options(options = {})
      options[:rewind_on_touch] ||= true
      options
    end

    def rewind_on_touch?(io)
      return unless @options[:rewind_on_touch]
      return unless @last_time < io.mtime
      io.rewind
      update_timestamp(io)
    end

    def update_timestamp(io)
      @last_time = @last_time.nil? ? io.stat.atime : io.mtime
    end
  end
end
