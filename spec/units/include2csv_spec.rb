# -*- encoding: utf-8 -*-

require "spec_helper"

module DummyForInclude2CSV
  class Foo
  end

  module Baz
  end

  class Bar < Foo
    include Baz
  end

  class Bar2 < Foo
  end
end

describe ProjectVisualizingHelpers::Include2CSV do
  describe 'base class is specified' do
    specify do
      expect = <<-EOS
DummyForInclude2CSV::Bar,iDummyForInclude2CSV::Baz
iDummyForInclude2CSV::Baz,DummyForInclude2CSV::Foo
      EOS

      ProjectVisualizingHelpers::Include2CSV.new(DummyForInclude2CSV::Bar).to_csv.should == expect
    end
  end

  describe 'not base class' do
    specify do
      result = ProjectVisualizingHelpers::Include2CSV.new.result
      expect = [
        ["DummyForInclude2CSV::Bar", "iDummyForInclude2CSV::Baz"],
        ["iDummyForInclude2CSV::Baz", "DummyForInclude2CSV::Foo"],
        ["DummyForInclude2CSV::Bar2", "DummyForInclude2CSV::Foo"],
        ["DummyForInclude2CSV::Foo", "Object"],
        ["Object", "iPP::ObjectMixin"],
        ["iPP::ObjectMixin", "iKernel"],
        ["iKernel", "BasicObject"]
      ]

      result.should be_all{|e| result.include?(e) }
    end
  end
end
