require 'perscribo/core/common'
require 'perscribo/support/core/dsl'

module Perscribo
  module Support
    module Core
      module IO
        include Dsl::Bootstrappable
        include Dsl::Refinements

        def hook!(base, level)
          stdio, io = base, base.clone
          bootstrap!(io.singleton_class)
          io.level = level
          io.stdio = stdio
        end

        publish! :hook!

        module Bootstraps
          module PrependMethods
            attr_accessor :level, :stdio

            DEFAULT_LEVEL = :info
            DEFAULT_STDIO = $stdout

            def write(s)
              s = "#{level}#{s}" if @last_write.nil?
              super(s.gsub("\n", "\n#{level}"))
              @last_write = s
            end

            private

            def level
              @level ||= DEFAULT_LEVEL
              Constants::MATCH_FORMAT.gsub(':level', '%s') % @level
            end
          end
        end

        module Helpers
          include Dsl::Refinements

          def capture_all(stderr = $stderr, stdout = $stdout, &block)
            $stderr = $stdout = fakeout = StringIO.new
            block.call
            fakeout.string
          ensure
            $stderr, $stdout = stderr, stdout
          end

          def capture_command(cmd)
            IO.popen(cmd).inject('') do |_, line|
              puts line.chomp
              line
            end
          end

          def capture_stderr(io = $stderr, &block)
            $stderr = fakeout = StringIO.new
            block.call
            fakeout.string
          ensure
            $stderr = io
          end

          def capture_stdout(io = $stdout, &block)
            $stdout = fakeout = StringIO.new
            block.call
            fakeout.string
          ensure
            $stdout = io
          end

          publish! :capture_command, :capture_stderr, :capture_stdout
        end
      end

      module LoggerIO
        # TODO: Set this up here too!
        # include Dsl::Bootstrappable
        include Dsl::Refinements

        def hook!(base, label, level, root_path)
          stdio, io = base, base.clone
          io.inside(label, level, root_path, stdio) do |a, b, c, d|
            singleton_class.send(:prepend, PrependHook)
            label, level, root_path, stdio = a, b, c, d
          end
        end

        publish! :hook!

        module PrependHook
          # TODO: Set defaults here and refactor rest

          # def self.prepended(base)
          #   base.inside do
          #     label, level, root_path, stdio = :stdout, :INFO, Dir.pwd, $stdout
          #   end
          # end

          attr_accessor :label, :level, :root_path, :stdio

          DEFAULT_LABEL = :stdout
          DEFAULT_LEVEL = :INFO
          DEFAULT_ROOT = Dir.pwd
          DEFAULT_STDIO = $stdout

          def write(s)
            @last_write = @last_write.nil? ? "\n#{s}" : s
            handle_writes!(@last_write)
          end

          def label
            @label ||= DEFAULT_LABEL
          end

          def level
            @level ||= DEFAULT_LEVEL
          end

          def logger
            @logger ||= Logging::SingletonLogger.instance(root_path, @label)
          end

          def root_path
            @root_path ||= DEFAULT_ROOT
          end

          def severity
            @severity ||= ::Logger::Severity::const_get(level.to_s.upcase)
          end

          def stdio
            @stdio ||= DEFAULT_STDIO
          end

          private

          def handle_writes!(last_write)
            return if last_write.try(:empty?) || last_write.nil?
            lines_ready?(last_write).each do |line|
              logger.add(severity, line, label.to_s)
            end
          end

          def lines_ready?(last_write)
            @log_buffer ||= ''
            @log_buffer << last_write
            lines = @log_buffer.split("\n")
            @log_buffer = lines.size > 1 ? lines.last : ''
            lines[0..(lines.size - 2)]
            # TODO: set a timeout to automatically dump remaining buffer after X seconds?
          end
        end
      end
    end
  end
end