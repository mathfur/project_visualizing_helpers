# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Railroad2CSV < Base
    def initialize(input)
      @lines = input.split(/\n/)

      parse
    end

    attr_reader :nodes, :edges

    PAIR_REGEX = /\w+=#{STRING_REGEX}/
    PAIRS_REGEX = /\s*#{PAIR_REGEX}\s*(,\s*#{PAIR_REGEX})*\s*/

    NODE_REGEX = /^ *"(?<model>[^"]+)" *\[(?<pairs>#{PAIRS_REGEX})\] *$/
    EDGE_REGEX = /^ *"(?<edge1>[^"]+)" *-> *"(?<edge2>[^"]+)" *\[(?<pairs>#{PAIRS_REGEX})\] *$/

    def parse
      @nodes = []
      @edges = []

      @lines.each do |line|
        case line
        when NODE_REGEX
          @nodes << $~[:model]
        when EDGE_REGEX
          @edges << [$~[:edge1], $~[:edge2]]

          @nodes << $~[:edge1]
          @nodes << $~[:edge2]
        end
      end

      @nodes = @nodes.sort.uniq
    end
  end
end
