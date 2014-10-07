require 'perscribo/format'

module Perscribo
  module IO
    attr_writer :label

    DEFAULT_LABEL = :info

    def write(s)
      s = "#{label}#{s}" if @last_write.nil?
      super(s.gsub("\n", "\n#{label}"))
      @last_write = s
    end

    private

    def label
      @label ||= DEFAULT_LABEL
      Perscribo::MATCH_FORMAT.gsub(':label', '%s') % @label
    end
  end
end
