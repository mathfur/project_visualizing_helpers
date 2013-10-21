# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class ClassDiagram2InstanceDiagram
    def initialize(input, opts={})
      @src_column    = opts[:src_column] || 0
      @dst_column    = opts[:dst_column] || 1
      @method_column = opts[:method_column] || 2

      case input
      when String
        @rows = CSV.parse(input)
      when Array
        @rows = input
      else
        raise ArgumentError, "input `#{input.inspect}` has to be String or Array"
      end
    end

    def source_to_output_edges
      hash = @rows.inject({}) do |h, row|
               h[row[@src_column]] ||= []
               h[row[@src_column]] << [row[@dst_column], row[@method_column]]
               h
             end

      ERB.new(<<-EOS, nil, '-').result(binding)
<%- hash.each do |src, dst_method_pairs| -%>
<%= src %>.all.each do |<%= src.underscore %>|
  <%- dst_method_pairs.each do |dst, method| -%>
  puts ['<%= src %>', '<%= dst %>', '<%= method %>', <%= src.underscore %>.id, <%= src.underscore %>.send("<%= method %>").id].join(',')
  <%- end -%>
end

<%- end -%>
      EOS
    end

    def source_to_output_nodes
      models = @rows.map{|row| [row[@src_column], row[@dst_column]]}.flatten.sort.uniq

      ERB.new(<<-EOS, nil, '-').result(binding)
<%- models.each do |model| -%>
<%= model %>.all.each do |<%= model.underscore %>|
  puts ['<%= model %>', <%= model.underscore %>.id].join(',')
end

<%- end -%>
      EOS
    end
  end
end
