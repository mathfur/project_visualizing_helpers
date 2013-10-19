# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::Railslog2CSV do
  describe "#result" do
    def convert(input)
      ProjectVisualizingHelpers::Railslog2CSV.new(input).result(
        :controller, :action, :time, :method, :param,
        :response_time, :view_time, :db_time, :response_code,
        :response_status, :url)
    end

    specify do
      expect = [
        ["Bar::FooController2", "export4", "2000-00-00 13:27:31", "POST", %Q!{"action"=>"export4", "controller" => "users4"}!, "27ms", "4", "5", "404", "Unauthorized", "http://localhost/baz/frt"],
        ["Bar::FooController3", "export5", "2000-00-00 14:28:32", "GET", %Q!{"action"=>"export5", "controller" => "users5"}!, "28ms", "5", "6", "404", "Unauthorized", "http://localhost/abc/def"]
      ]
      convert(<<-EOS).should == expect
Processing Bar::FooController2#export4 (for 127.0.0.1 at 2000-00-00 13:27:31) [POST]
Parameters: {"action"=>"export4", "controller" => "users4"}
SELECT * FROM blogs4;
Completed in 27ms (View: 4, DB: 5) | 404 Unauthorized [http://localhost/baz/frt]

Processing Bar::FooController3#export5 (for 127.0.0.1 at 2000-00-00 14:28:32) [GET]
Parameters: {"action"=>"export5", "controller" => "users5"}
SELECT * FROM blogs5;
Completed in 28ms (View: 5, DB: 6) | 404 Unauthorized [http://localhost/abc/def]
EOS
    end
  end
end
