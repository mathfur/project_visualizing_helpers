# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Graph
    def initialize(center, edges)
      @center = center
      @edges = edges.to_a

      unless @edges.flatten.include?(center)
        raise "@edges `#{@edges.inspect}` has to have @center `#{@center.inspect}`"
      end
    end

    def tree
      @tree_nodes = [@center]

      tree_edges = []
      while @edges.present?
        selected_edge = @edges.each do |edge|
                          if (from = (@tree_nodes & edge).try(:first))
                            to = (edge - [from]).first
                            @tree_nodes << to

                            tree_edges << [from, to]
                            break edge
                          end
                        end

        if selected_edge
          @edges -= [selected_edge]
        else
          break
        end
      end

      tree_edges
    end
  end
end
