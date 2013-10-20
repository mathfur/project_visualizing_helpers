# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::Graph do
  describe '#initialize' do
    it 'can read from csv string' do
      ProjectVisualizingHelpers::Graph.new(<<-EOS, :center => "foo").edges.should == [["foo", "b\"ar"], ["foo", "baz"]]
foo,"b""ar"
foo,baz
      EOS
    end
  end

  describe '#tree' do
    def graph2tree(center, hash)
      ProjectVisualizingHelpers::Graph.new(hash, :center => center).tree
    end

    describe '2 node' do
      specify { graph2tree(1, [[1, 2]]).should == [[1, 2]] }
      specify { graph2tree(2, [[1, 2]]).should == [[2, 1]] }
      specify { lambda{ graph2tree(3, [[1, 2]]) }.should raise_error }

      specify { graph2tree(:foo, [[:foo, :bar]]).should == [[:foo, :bar]] }
    end

    describe '3 node' do
      specify { graph2tree(1, [[1, 2], [2, 3]]).should == [[1, 2], [2, 3]] }
      specify { graph2tree(2, [[1, 2], [2, 3]]).should == [[2, 1], [2, 3]] }
      specify { graph2tree(3, [[1, 2], [2, 3]]).should == [[3, 2], [2, 1]] }

      specify { graph2tree(1, [[1, 2], [2, 3], [3, 1]]).should == [[1, 2], [2, 3]] }
    end
  end

  describe '#tree_by_csv' do
    specify do
      ProjectVisualizingHelpers::Graph.new([['foo', 'ba"r'], ['ba"r', 'baz']], :center => "foo").
        tree_by_csv.should == %Q!foo,"ba""r"\n"ba""r",baz\n!
    end
  end
end
