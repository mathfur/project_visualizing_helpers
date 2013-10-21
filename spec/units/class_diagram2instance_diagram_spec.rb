# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::ClassDiagram2InstanceDiagram do
  let(:rows1){ [
      %w{Buy User user},
      %w{Buy Product product}
  ]}

  describe '#source_to_output_node' do
    def node_source(input)
      ProjectVisualizingHelpers::ClassDiagram2InstanceDiagram.new(input).source_to_output_nodes
    end

    specify do
      node_source(rows1).should == <<-EOS
Buy.all.each do |buy|
  puts ['Buy', buy.id].join(',')
end

Product.all.each do |product|
  puts ['Product', product.id].join(',')
end

User.all.each do |user|
  puts ['User', user.id].join(',')
end

      EOS
    end
  end

  describe '#source_to_output_edge' do
    def edge_source(input)
      ProjectVisualizingHelpers::ClassDiagram2InstanceDiagram.new(input).source_to_output_edges
    end

    specify do
      edge_source(rows1).should == <<-EOS
Buy.all.each do |buy|
  puts ['Buy', 'User', 'user', buy.id, buy.send("user").id].join(',')
  puts ['Buy', 'Product', 'product', buy.id, buy.send("product").id].join(',')
end

      EOS
    end
  end
end
