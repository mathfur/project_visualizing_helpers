# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::Graph do
  describe '#initialize' do
    def graph2tree(center, hash)
      ProjectVisualizingHelpers::Graph.new(center, hash).tree
    end

    describe '2 node' do
      specify { graph2tree(1, [[1, 2]]).should == [[1, 2]] }
      specify { graph2tree(2, [[1, 2]]).should == [[2, 1]] }
      specify { lambda{ graph2tree(3, [[1, 2]]) }.should raise_error }
    end

    describe '3 node' do
      specify { graph2tree(1, [[1, 2], [2, 3]]).should == [[1, 2], [2, 3]] }
      specify { graph2tree(2, [[1, 2], [2, 3]]).should == [[2, 1], [2, 3]] }
      specify { graph2tree(3, [[1, 2], [2, 3]]).should == [[3, 2], [2, 1]] }
    end
  end
end
