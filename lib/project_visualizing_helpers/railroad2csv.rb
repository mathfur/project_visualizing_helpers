# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Railroad2CSV
    def initialize(input)
      @lines = input.split(/\n/)

      parse
    end

    attr_reader :nodes, :edges

    CH_REG = /(\\"|[^"])/
    NOT_QUOTED_REG = /"#{CH_REG}*"/
    QUOTED_REG = /\w+/
    PAIR_VALUE_REG = /(#{NOT_QUOTED_REG}|#{QUOTED_REG})/
    PAIR_REG = /\w+=#{PAIR_VALUE_REG}/
    PAIRS_REG = /\s*#{PAIR_REG}\s*(,\s*#{PAIR_REG})*\s*/

    NODE_REG = /^ *"(?<model>[^"]+)" *\[(?<pairs>#{PAIRS_REG})\] *$/
    EDGE_REG = /^ *"(?<edge1>[^"]+)" *-> *"(?<edge2>[^"]+)" *\[(?<pairs>#{PAIRS_REG})\] *$/

    def parse
      @nodes = []
      @edges = []

      @lines.each do |line|
        case line
        when NODE_REG
          @nodes << $~[:model]
        when EDGE_REG
          @edges << [$~[:edge1], $~[:edge2]]

          @nodes << $~[:edge1]
          @nodes << $~[:edge2]
        end
      end

      @nodes = @nodes.sort.uniq
    end
  end
end
