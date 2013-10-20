# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class DbSchema2CSV < Base
    def initialize(input)
      @lines = input.split(/\n/)

      parse
    end

    TABLE_REGEX = /^ *create_table :(?<table_name>\w+)(, .+?)? do \|t\| *$/
    COLUMN_REGEX = /^ *t\.column :(?<column_name>\w+), :(?<column_type>\w+)(?:,(?<column_opts>.*?))?$/

    def parse
      @output = []
      state = :outside
      @debug_stack = []

      table_name = nil
      @lines.each do |line|
        case line
        when TABLE_REGEX
          @debug_stack << [state, :table]

          table_name = $~[:table_name]

          state = :table_def
        when COLUMN_REGEX
          @debug_stack << [state, :column_def]

          column_name = $~[:column_name]
          column_type = $~[:column_type]
          column_opts = $~[:column_opts]
          column_limit = (column_opts || '')[/:limit *=> *(\d+)\b/, 1]

          raise "table_name is not defined" unless table_name

          @output << [table_name, column_name, column_type, column_limit]
        end
      end
    end

    def headers
      %w{table column type limit}
    end
  end
end
