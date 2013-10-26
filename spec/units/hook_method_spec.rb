# -*- encoding: utf-8 -*-

require "spec_helper"

class DummyClassForHookMethod
  def foo(name)
  end

  def self.bar(name)
  end
end

describe ProjectVisualizingHelpers::HookMethod do
  describe '.hook' do
    specify do
      f = Tempfile.open("hook_method")

      ProjectVisualizingHelpers::HookMethod.hook(DummyClassForHookMethod, f)

      DummyClassForHookMethod.new.foo("abc")
      DummyClassForHookMethod.bar("def")

      f.close

      File.read(f.path).should == <<-EOS
in,foo,"abc"
out,foo
in,bar,"def"
out,bar
      EOS
    end
  end
end
