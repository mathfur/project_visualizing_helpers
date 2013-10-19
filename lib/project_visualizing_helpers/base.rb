# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Base
    def result(*columns)
      indexes = columns.map{|col| self.headers.index(col.to_s) }

      raise ArgumentError, columns if indexes.include?(nil)

      @output.map{|line| indexes.map{|i| line[i] } }
    end

    QUOTED_CHARACTER_REGEX = /(\\"|[^"])/
    INNER_QUOTE_REGEX = /#{QUOTED_CHARACTER_REGEX}*/
    QUOTED_STRING_REGEX = /"#{INNER_QUOTE_REGEX}*"/
    NOT_QUOTED_STRING_REGEX = /\w+/
    STRING_REGEX = /(?:#{NOT_QUOTED_STRING_REGEX}|#{QUOTED_STRING_REGEX})/
  end
end
