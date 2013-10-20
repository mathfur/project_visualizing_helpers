# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Base
    def result(*columns)
      indexes = if columns.blank?
                  (0..self.headers.size-1).to_a
                else
                  columns.map{|col| self.headers.index(col.to_s) }
                end

      raise ArgumentError, columns if indexes.include?(nil)

      @output.map{|line| indexes.map{|i| line[i] } }
    end

    QUOTED_CHARACTER_REGEX = /(\\"|[^"])/
    INNER_QUOTE_REGEX = /#{QUOTED_CHARACTER_REGEX}*/
    QUOTED_STRING_REGEX = /"#{INNER_QUOTE_REGEX}*"/
    NOT_QUOTED_STRING_REGEX = /\w+/
    STRING_REGEX = /(?:#{NOT_QUOTED_STRING_REGEX}|#{QUOTED_STRING_REGEX})/

    IP_REGEX = /(?<ip>\b\d{1,3}(\.\d{1,3}){3}\b)/
    TIME_REGEX1 = /(?<time>\b\d+-\d+-\d+ \d+:\d+:\d+\b)/
    METHOD_REGEX = /(?<method>\b(?:GET|POST|DELETE|PUT|HEAD))/

    def result_by_csv(*args)
      self.result(*args).map(&:to_csv).join
    end
  end
end
