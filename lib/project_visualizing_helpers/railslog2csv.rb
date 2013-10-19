# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Railslog2CSV < Base
    def initialize(input)
      @lines = input.split(/\n/)

      parse
    end

    HEAD_LINE_REGEX = /^Processing (?<controller>[^#]+)#(?<action>[^ ]+) \(for #{IP_REGEX} at #{TIME_REGEX1}\) \[#{METHOD_REGEX}\]$/
    PARAM_LINE_REGEX =/^ *Parameters: (?<param>.*)$/
    COMPLETE_LINE_REGEX = /^Completed in (?<response_time>[^ ]+) \(View: (?<view_time>\d+), DB: (?<db_time>\d+)\) \| (?<response_code>\d+) (?<response_status>\w+) \[(?<url>[^\]]+)\]$/

    def parse
      @output = []
      state = :outside
      @debug_stack = []

      while line = @lines.shift
        case state
        when :outside
          case line
          when HEAD_LINE_REGEX
            @debug_stack << [:outside, :head]

            controller = $~[:controller]
            action = $~[:action]
            ip = $~[:ip]
            time = $~[:time]
            method = $~[:method]

            state = :head
          end
        when :head
          case line
          when PARAM_LINE_REGEX
            @debug_stack << [:head, :param]

            param = $~[:param]
            state = :param
          else
            raise "`#{line}` is not match /#{PARAM_LINE_REGEX.inspect}/"
          end
        when :param
          case line
          when COMPLETE_LINE_REGEX
            @debug_stack << [:param, :complete]

            response_time = $~[:response_time]
            view_time = $~[:view_time]
            db_time = $~[:db_time]
            response_code = $~[:response_code]
            response_status = $~[:response_status]
            url = $~[:url]

            @output << [controller, action, ip, time, method, param, response_time, view_time, db_time, response_code, response_status, url]

            state = :outside
          else
            # SQLなどの処理
          end
        end
      end
    end

    def headers
      %w{controller action ip time method param response_time view_time db_time response_code response_status url}
    end
  end
end
