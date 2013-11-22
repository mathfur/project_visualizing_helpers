# -*- encoding: utf-8 -*-

require "spec_helper"

describe "helper.py" do
  let(:rb_fname_pattern){ Regexp.escape(File.basename(TMP_RUBY_SOURCE)) }

  describe '#get_class_name' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
obj = Object.new
klass = Class.new
pr = Proc.new { }
puts({}, "foo", obj, [], :foo, 1, nil, false, true, klass, pr)
RB_SOURCE
argc > 1
BREAK_STATMENT
argc = int(frame.EvaluateExpression('argc').GetValue())
for i in range(argc):
  value = frame.FindVariable("argv").GetValueForExpressionPath("[%s]" % i)
  #value = frame.FindVariable("argv[%d]" % i)
  print h.get_class_name(value)
APPEND_STATEMENT

      results[0].should == "Hash"
      results[1].should == "String"
      results[2].should == "Object"
      results[3].should == "Array"
      results[4].should == "None"
      results[5].should == "None"
      results[6].should == "None"
      results[7].should == "None"
      results[8].should == "None"
      results[9].should =~ /^#<Class\b/
      results[10].should == "Proc"
      results.size.should == 11
    end
  end

  describe '#get_ruby_object_type' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
obj = Object.new
klass = Class.new
pr = Proc.new { }
puts({}, "foo", obj, [], :foo, 1, nil, false, true, klass, pr)
RB_SOURCE
argc > 1
BREAK_STATMENT
argc = int(frame.EvaluateExpression('argc').GetValue())
for i in range(argc):
  value = frame.FindVariable("argv").GetValueForExpressionPath("[%s]" % i)
  print h.get_ruby_object_type(value)
APPEND_STATEMENT

      results[0].should == '11'
      results[1].should == '7'
      results[2].should == '2'
      results[3].should == '9'
      results[4].should == "None"
      results[5].should == "None"
      results[6].should == "None"
      results[7].should == "None"
      results[8].should == "None"
      results[9].should == '3'
      results[10].should == '34'
      results.size.should == 11
    end
  end

  describe '#inspect_value' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts('foo', :bar, 30, true, false, nil, [1, 2])
RB_SOURCE
argc > 1
BREAK_STATMENT
argc = int(frame.EvaluateExpression('argc').GetValue())
for i in range(argc):
  str = frame.FindVariable("argv").GetValueForExpressionPath("[%s]" % i)
  print h.inspect_value(str)
APPEND_STATEMENT

     results[0].should == "'foo'"
     results[1].should == ":bar"
     results[2].should == "30"
     results[3].should == "true"
     results[4].should == "false"
     results[5].should == "nil"
     results[6].should == "[1, 2]"
    end

    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts(135, nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
x = frame.FindVariable("argv").GetValueForExpressionPath("[0]")
print h.inspect_value(x)
APPEND_STATEMENT

      results[0].should == "135"
    end
  end

  describe '#inspect_string' do
    it 'when ELTS_SHARED flag is false' do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
print('foo', nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
str = frame.FindVariable("argv").GetValueForExpressionPath("[0]")
print h.inspect_string(str)
APPEND_STATEMENT

     results[0].should == "'foo'"
    end

    it 'when ELTS_SHARED flag is true' do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
9.times do |i|
  x = 'foo'
  p(x, nil)
end
RB_SOURCE
argc > 1
BREAK_STATMENT
str = frame.FindVariable("argv").GetValueForExpressionPath("[0]")
print h.inspect_string(str)
APPEND_STATEMENT

     results[0].should == "'foo'"
    end
  end

  describe '#inspect_symbol' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts(:foo, nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
str = frame.FindVariable("argv").GetValueForExpressionPath("[0]")
print h.inspect_symbol(str)
APPEND_STATEMENT

      results[0].should == ':foo'
    end
  end

  describe '#inspect_integer' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts(15, nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
num = frame.FindVariable("argv").GetValueForExpressionPath("[0]")
print h.inspect_integer(num)
APPEND_STATEMENT

      results[0].should == '15'
    end
  end

  describe '#inspect_bool' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts(true, false, nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
argc = int(frame.EvaluateExpression('argc').GetValue())
for i in range(argc):
  str = frame.FindVariable("argv").GetValueForExpressionPath("[%d]" % i)
  print h.inspect_bool(str)
APPEND_STATEMENT

      results[0].should == 'true'
      results[1].should == 'false'
      results[2].should == 'nil'
    end
  end

  describe '#inspect_array' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts([:foo, 135, 'bar', nil, true, false], nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
x = frame.FindVariable("argv").GetValueForExpressionPath("[0]")
print h.inspect_array(x)
APPEND_STATEMENT

      results[0].should == "[:foo, 135, 'bar', nil, true, false]"
    end

    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts([[12, 34], 56], nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
x = frame.FindVariable("argv").GetValueForExpressionPath("[0]")
print h.inspect_array(x)
APPEND_STATEMENT

      results[0].should == "[[12, 34], 56]"
    end
  end

  describe '#have_valid_flags' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts(nil, 3, :foo, [], "foo", {},  nil)
RB_SOURCE
argc > 1
BREAK_STATMENT
for i in range(6):
  x = frame.FindVariable("argv").GetValueForExpressionPath("[%d]" % i)
  print h.have_valid_flags(x)
APPEND_STATEMENT

      results[0].should == "False"
      results[1].should == "False"
      results[2].should == "False"
      results[3].should == "True"
      results[4].should == "True"
      results[5].should == "True"
    end
  end

  describe '#get_node_type' do
    specify do
      results = execute_with_break(<<RB_SOURCE, [['eval.c', 2979], ['eval.c', 4183]], <<APPEND_STATEMENT)
if true
else
end
RB_SOURCE
node = frame.FindVariable('node')
print h.get_node_type(node)
APPEND_STATEMENT

      results.should be_include('NODE_NEWLINE')
      results.should be_include('NODE_TRUE')
      results.should be_include('NODE_IF')
    end

    specify do
      results = execute_with_break(<<RB_SOURCE, [['eval.c', 2979], ['eval.c', 4183]], <<APPEND_STATEMENT)
i = 0
while i < 3
  i += 1
  puts i
end
RB_SOURCE
node = frame.FindVariable('node')
print h.get_node_type(node)
APPEND_STATEMENT

      results.should be_include('NODE_NEWLINE')

      results.should be_include('NODE_WHILE')
      results.should be_include('NODE_BLOCK')

      results.should be_include('NODE_LIT')
      results.should be_include('NODE_LASGN')
      results.should be_include('NODE_LVAR')
      results.should be_include('NODE_CALL')
      results.should be_include('NODE_FCALL')
    end

    specify do
      results = execute_with_break(<<RB_SOURCE, [['eval.c', 2979], ['eval.c', 4183]], <<APPEND_STATEMENT)
class Foo
end
Foo.new
RB_SOURCE
node = frame.FindVariable('node')
print h.get_node_type(node)
APPEND_STATEMENT

      results.should be_include('NODE_NEWLINE')

      results.should be_include('NODE_CLASS')
      results.should be_include('NODE_BLOCK')

      results.should be_include('NODE_CONST')
      results.should be_include('NODE_CALL')
    end
  end

  describe '#enhance_method_missing' do
    specify do
      output = execute_plain(<<RB_SOURCE, <<BREAK_STATMENT)
arr1 = [1, 2, 3]
arr2 = [4, 5, 6]
arr3 = nil
p arr1.sort + arr2.sort + arr3.sort
RB_SOURCE
h.enhance_method_missing()
BREAK_STATMENT

      output.should =~ /type.*NODE_CALL/
    end
  end

  describe '#print_backtrace' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
def bar
  puts(1, 2)
end
def foo
  bar
end
foo
RB_SOURCE
BREAK_STATMENT
h.print_backtrace()
APPEND_STATEMENT

      rb_fname_pattern = Regexp.escape(File.basename(TMP_RUBY_SOURCE))
      results.should be_any{|line| line =~ /#{rb_fname_pattern}:2:in `bar`$/}
      results.should be_any{|line| line =~ /#{rb_fname_pattern}:5:in `foo`$/}
      results.should be_any{|line| line =~ /#{rb_fname_pattern}:7:$/}
    end
  end

  describe '#local_vars' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
a10 = 10
b20 = 100

def foo(x,y)
  abc = 10
  print 'hello'
  defg = 15
end

foo(1,2)
RB_SOURCE
BREAK_STATMENT
if h.get_func_name() == 'foo':
  for k, v in h.local_vars().items():
    print "%s: %s" % (k, h.inspect_value(v))
APPEND_STATEMENT

      results.should be_include(': nil')
      results.should be_include('~: nil')
      results.should be_include('x: 1')
      results.should be_include('y: 2')
      results.should be_include('abc: 10')
      results.should be_include('defg: nil')
      results.size.should == 6
    end
  end

  describe '#get_func_name' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
def bar
  puts(1, 2)
end
def foo
  bar
end
foo
RB_SOURCE
argc > 1
BREAK_STATMENT
print h.get_func_name()
APPEND_STATEMENT

      results.should be_include('bar')
      results.size.should == 1
    end
  end

  describe '#inspect_node' do
    specify do
      results = execute_with_break(<<RB_SOURCE, [['eval.c', 2979], ['eval.c', 4183]], <<APPEND_STATEMENT)
puts(10)
RB_SOURCE
node = frame.FindVariable('node')
if h.get_node_type(node) == 'NODE_FCALL':
  pp.pprint(h.inspect_node(node))
  print ", "
APPEND_STATEMENT

      require "json"
      json_source = "[" + results.join("\n").gsub(/u?'/){ '"' } + " null]"
      results = JSON.parse(json_source)
      results[0]['u3']['node']['u1']['node']['u1']['value'].should == "10"
    end

    specify do
      #results = execute_with_break(<<RB_SOURCE, [['main.c', 48]], <<APPEND_STATEMENT)
      results = execute_with_break(<<RB_SOURCE, {'ruby_run' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts(10)
RB_SOURCE
BREAK_STATMENT
ruby_eval_tree = frame.EvaluateExpression('(NODE *) ruby_eval_tree')
pp.pprint(h.inspect_node(ruby_eval_tree))
print ", "
break
APPEND_STATEMENT

      require "json"
      json_source = "[" + results.join("\n").gsub(/u?'/){ '"' } + " null]"
      results = JSON.parse(json_source)
      results[0]['u3']['node']['u3']['node']['type'].should == "NODE_ARRAY"
      results[0]['u3']['node']['u3']['node']['u1']['node']['type'].should == 'NODE_LIT'
      results[0]['u3']['node']['u3']['node']['u1']['node']['u1']['value'].should == '10'
    end
  end

  describe '#get_node_by_xml' do
    specify do
      results = execute_with_break(<<RB_SOURCE, [['eval.c', 2979], ['eval.c', 4183]], <<APPEND_STATEMENT)
if true
  puts(10)
else
  1 + 3
end
RB_SOURCE
node = frame.FindVariable('node')
if h.get_node_type(node) == 'NODE_FCALL':
  print h.get_node_by_xml(node)
APPEND_STATEMENT

      require "rexml/document"
      doc = REXML::Document.new("<all>#{results.join("\n")}</all>")
      REXML::XPath.first(doc, "//type[text()='NODE_FCALL']").should be_true
      REXML::XPath.first(doc, "//type[text()='NODE_IF']").should be_false
      REXML::XPath.first(doc, "//type[text()='NODE_ARRAY']").should be_true
      REXML::XPath.first(doc, "//type[text()='NODE_LIT']").should be_true
      REXML::XPath.first(doc, "//node[@value='10']").should be_true
    end
  end

  describe '#observe_call' do
    specify do
      results = execute_plain(<<RB_SOURCE, <<BREAK_STATMENT)
puts "123".to_i
{:x => 10, :y => 20}.merge({})
{:x => 10, :y => 20}.values_at(:x, :y)
{}.inspect
puts 123.to_s
RB_SOURCE
h.observe_call('Hash')
BREAK_STATMENT

      results = results.split(/\n/)
      results.find{|r| r =~ /to_i/}.should be_false
      results.find{|r| r =~ /merge/}.should be_true
      results.find{|r| r =~ /values_at.*:x.*:y/}.should be_true
      results.find{|r| r =~ /inspect\(\)/}.should be_true
      results.find{|r| r =~ /to_s/}.should be_false
    end
  end

  describe '#current_line' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
def bar
  puts(1, 2)
end
def foo
  bar
end
foo
RB_SOURCE
argc > 1
BREAK_STATMENT
print "current_line = %d;" % h.current_line()
APPEND_STATEMENT

      results.should be_include("current_line = 2;")
    end
  end

  describe '#current_fname' do
    specify do
      results = execute_with_break(<<RB_SOURCE, {'rb_call' => <<BREAK_STATMENT}, <<APPEND_STATEMENT)
puts(1, 2, 3)
RB_SOURCE
argc > 1
BREAK_STATMENT
print "current_fname = %s;" % h.current_fname()
APPEND_STATEMENT

      results.should be_any{|line| line =~ /current_fname = .*#{rb_fname_pattern};/}
    end
  end

  def execute_with_break(rb_src, break_statements, appending_src, options={})
    breakpoint_set_statement = if break_statements.kind_of?(Array)
                                 break_statements.map do |fname, lnum|
                                   "target.BreakpointCreateByLocation('#{fname}', #{lnum})"
                                 end
                               else
                                 break_statements.map do |func_name, break_stat|
                                   [
                                     %Q!bp = target.BreakpointCreateByName("#{func_name}", target.GetExecutable().GetFilename());\n!,
                                     break_stat.split("\n").map{|line| %Q!bp.SetCondition("#{line.strip}")\n! }
                                   ]
                                 end.flatten
                               end

    execute0(rb_src, common_python_src_for_dummy(breakpoint_set_statement.join("\n"), <<-EOS), options)
        while True:
            state = process.GetState ()
            if state == lldb.eStateStopped:
                thread = process.GetThreadAtIndex (0)
                if thread:
                    frame = thread.GetFrameAtIndex (0)
                    h = helper.LLDBFrame(target, process, frame)
                    function = frame.GetFunction()
                    if function:
#{appending_src.split("\n").map{|stat| "#{' '*24}#{stat}"}.join("\n")}
                    process.Continue()
            else:
                break
EOS
  end

  def execute_plain(rb_src, breakpoint_set_statement, options={})
    execute0(rb_src, common_python_src_for_dummy(breakpoint_set_statement, <<-EOS), options.merge(:all => true))
        state = process.GetState ()
        if state == lldb.eStateStopped:
            thread = process.GetThreadAtIndex (0)
            if thread:
                frame = thread.GetFrameAtIndex (0)
                h = helper.LLDBFrame(target, process, frame)
EOS
  end

  def common_python_src_for_dummy(breakpoint_set_statement, inner)
    <<EOS
import lldb
import os
import pprint

import lib.python.lldb_helper as helper

pp = pprint.PrettyPrinter(2)

exe = "#{DEBUG_BUILD_RUBY_PATH}"
rb_fname = "#{TMP_RUBY_SOURCE}"

debugger = lldb.SBDebugger.Create()
debugger.SetAsync (False)

target = debugger.CreateTargetWithFileAndArch (exe, lldb.LLDB_ARCH_DEFAULT)
res = lldb.SBCommandReturnObject()
print "APPENDING_SRC_RESULT_START"

if target:
    h = helper.LLDBFrame(target, None, None)
#{breakpoint_set_statement.split("\n").map{|stat| "    #{stat}"}.join("\n")}

    process = target.LaunchSimple ([rb_fname], None, os.getcwd())
    if process:
#{inner}

print "APPENDING_SRC_RESULT_END"
EOS
  end

  def execute0(rb_src, breaked_python_src, options={})
    open(TMP_PYTHON_SOURCE, 'w'){|f| f.write breaked_python_src }
    open(TMP_RUBY_SOURCE, 'w'){|f| f.write rb_src }

    command = "python #{TMP_PYTHON_SOURCE} 2>&1"

    test_output = []
    io = IO.popen(command, 'r')
    while line = io.gets
      test_output << line
    end

    Process.kill('KILL', io.pid)
    io.close

    if options[:multiple]
      test_output.join.scan(/APPENDING_SRC_RESULT_START(.*?)APPENDING_SRC_RESULT_END/m).flatten.map(&:strip).sort.uniq
    elsif options[:all]
      test_output.join
    else
      (test_output.join[/APPENDING_SRC_RESULT_START(.*?)APPENDING_SRC_RESULT_END/m, 1] || '').strip.split(/\n/)
    end
  end
end
