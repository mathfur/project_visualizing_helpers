# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class MySQLLog2CSV
    def initialize(*args)
      case args[0]
      when String
        @lines = args[0].split(/\n/)
      end

      parse
    end

    COMMANDS = %w{Query Connect Quit Shutdown}

    COMMAND_REG        = /(#{COMMANDS.join('|')})/
    HEADER_LINE_REG    = /^ *Time +Id +Command +Argument *$/
    TIMED_LINE_REG     = /^(?<num>\d+)\s+(?<time>\d{2}:\d{2}:\d{2})\s+(\d+)\s+(?<command>#{COMMAND_REG})(\s+(?<argument>.*))?$/
    NOT_TIMED_LINE_REG = /^\s+(\d+)\s+(?<command>#{COMMAND_REG})(\s+(?<argument>.*))?$/

    def parse
      @output = []
      state = :start
      @debug_stack = []

      while line = @lines.shift
        case state
        when :start
          case line
          when HEADER_LINE_REG
            @debug_stack << [state, :header_line_reg]
            state = :in_processing
          else
            @debug_stack << [state, :else]
          end
        when :in_processing
          case line
          when TIMED_LINE_REG
            @debug_stack << [state, :timed_line_reg]

            num = $~[:num]
            time = $~[:time]
            command = $~[:command]
            statement = $~[:argument]

            @output << [num, time, command, statement]
          when NOT_TIMED_LINE_REG
            @debug_stack << [state, :not_timed_line_reg]

            command = $~[:command]
            statement = $~[:argument]

            @output << [num, time, command, statement]
          when HEADER_LINE_REG
            @debug_stack << [state, :header_line_reg]

            state = :in_processing
          else
            @debug_stack << [state, :else]

            if last_output = @output.pop
              last_output[-1] = last_output[-1] + "\n" + line
              @output << last_output
            end
          end
        else
          raise "Wrong state"
        end
      end
    end

    def result(*columns)
      headers = %w{num time command argument}
      indexes = columns.map{|col| headers.index(col.to_s) }

      raise ArgumentError, columns if indexes.include?(nil)

      @output.map{|line| indexes.map{|i| line[i] } }
    end
  end
end

__END__
