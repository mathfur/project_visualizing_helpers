# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Graph
    attr_reader :edges

    def initialize(edges, opts={})
      case edges
      when Array, Hash
        @edges = edges.to_a
      when String
        @edges = CSV.parse(edges).to_a
      end

      @center = opts[:center] || @edges.first.first

      unless @edges.flatten.include?(@center)
        raise "@edges `#{@edges.inspect}` has to have @center `#{@center.inspect}`"
      end
    end

    def tree
      @tree_nodes = [@center]

      tree_edges = []
      @edges.size.times do
        selected_edge = nil

        @edges.each do |edge|
          if (intersection = (@tree_nodes & edge)) && (intersection.size == 1)
            from = intersection.first
            to = (edge - [from]).first
            @tree_nodes << to

            tree_edges << [from, to]
            selected_edge = edge
            break
          end
        end

        if selected_edge
          raise "@edges `#{@edges.inspect}` has to have selected_edge `#{selected_edge}`" unless @edges.include?(selected_edge)
          @edges -= [selected_edge]
        end
      end

      if @tree_nodes.size == @edges.flatten.sort.uniq.size
        raise "This graph is not connected"
      end

      tree_edges
    end

    def tree_by_csv
      self.tree.map(&:to_csv).join
    end
  end
end
