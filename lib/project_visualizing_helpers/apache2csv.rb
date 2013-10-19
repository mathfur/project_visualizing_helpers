# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Apache2CSV < Base
    def initialize(input)
      @lines = input.split(/\n/)

      parse
    end

    QUOTED_CHARACTER = /(\\"|[^"])/
    INNER_QUOTE_REG = /#{QUOTED_CHARACTER}*/

    IP_REG = /\b\d{1,3}(\.\d{1,3}){3}\b/
    LINE_REG = /^(?<ip>#{IP_REG}) [^ ]+ [^ ]+ \[(?<time>[^\]]+)\] "(?<query>#{INNER_QUOTE_REG}*)" (?<code>\d+) (?<bytes>\d+)$/

    def parse
      @output = @lines.map{|line| line.scan(LINE_REG).first}.compact
    end

    def headers
      %w{ip time query code bytes}
    end
  end
end
