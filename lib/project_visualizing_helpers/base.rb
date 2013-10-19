# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Base
    def result(*columns)
      indexes = columns.map{|col| self.headers.index(col.to_s) }

      raise ArgumentError, columns if indexes.include?(nil)

      @output.map{|line| indexes.map{|i| line[i] } }
    end
  end
end
