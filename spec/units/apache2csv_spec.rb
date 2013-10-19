# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::Apache2CSV do
  describe '#initialize' do
    specify do
      input = <<-EOS
127.0.0.1 - foo [10/Oct/2000:13:55:36 -0700] "GET /foo.gif HTTP/1.0" 200 2326
127.0.0.1 - - [10/Oct/2000:14:56:37 -0700] "GET /bar.gif HTTP/1.0" 404 10
EOS
      ProjectVisualizingHelpers::Apache2CSV.new(input).
        result(:ip, :time, :query, :code, :bytes).should == [
          ["127.0.0.1", "10/Oct/2000:13:55:36 -0700", "GET /foo.gif HTTP/1.0", "200", "2326"],
          ["127.0.0.1", "10/Oct/2000:14:56:37 -0700", "GET /bar.gif HTTP/1.0", "404", "10"]
        ]
    end
  end
end
