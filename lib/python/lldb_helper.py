import lldb
import commands
import optparse
import shlex
import pprint
import json

def enhance_method_missing_handler(dbg, frame):
  lldb_frame = LLDBFrame(None, None, frame)
  try:
    pp = pprint.PrettyPrinter(2)
    thread = frame.GetThread()
    for f in thread:
      if f.GetFunctionName() == 'rb_eval':
        node = f.EvaluateExpression('node')
        pp.pprint(lldb_frame.inspect_node(node))
        break
    dbg.HandleCommand("continue")
  except Exception as ex:
    print ex
    raise

def observe_call_handler(dbg, frame, klass_name):
  try:
    lldb_frame = LLDBFrame(None, None, frame)
    recv = frame.EvaluateExpression('recv')
    mid  = frame.EvaluateExpression('mid')
    argc = frame.EvaluateExpression('argc').GetValue()
    argv = frame.EvaluateExpression('argv')
    if lldb_frame.get_class_name(recv) == klass_name:
      args = map((lambda i:
        lldb_frame.inspect_value(argv.GetValueForExpressionPath("[%d]" % i))
        ), range(int(argc)))
      print "%s#%s(%s)" % (lldb_frame.inspect_value(recv), lldb_frame.id2name(mid), ', '.join(args))
    dbg.HandleCommand("continue")
  except Exception as ex:
    print ex
    raise

class LLDBFrame(object):
  #=========================== helper module
  available_children = [
    ('NODE_METHOD', []),
    ('NODE_FBODY', []),
    ('NODE_CFUNC', []),
    ('NODE_SCOPE', [['u3', 'node'], ['u2', 'value'], ['u1', 'tbl']]),
    ('NODE_BLOCK', [['u1', 'node'], ['u3', 'node']]),
    ('NODE_IF', [['u1', 'node'], ['u2', 'node'], ['u3', 'node']]),
    ('NODE_CASE', [['u1', 'node'], ['u2', 'node'], ['u3', 'node']]),
    ('NODE_WHEN', [['u1', 'node'], ['u2', 'node'], ['u3', 'node']]),
    ('NODE_OPT_N', [['u2', 'node']]),
    ('NODE_WHILE', [['u1', 'node'], ['u2', 'node'], ['u3', 'state']]),
    ('NODE_UNTIL', [['u1', 'node'], ['u2', 'node'], ['u3', 'state']]),
    ('NODE_ITER', [['u1', 'node'], ['u2', 'node'], ['u3', 'node']]),
    ('NODE_FOR', [['u1', 'node'], ['u2', 'node'], ['u3', 'node']]),
    ('NODE_BREAK', [['u1', 'node']]),
    ('NODE_NEXT', [['u1', 'node']]),
    ('NODE_REDO', []),
    ('NODE_RETRY', []),
    ('NODE_BEGIN', [['u2', 'node']]),
    ('NODE_RESCUE', [['u1', 'node'], ['u2', 'node'], ['u3', 'node']]),
    ('NODE_RESBODY', []),
    ('NODE_ENSURE', [['u1', 'node'], ['u3', 'node']]),
    ('NODE_AND', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_OR', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_NOT', [['u2', 'node']]),
    ('NODE_MASGN', [['u2', 'node']]),
    ('NODE_LASGN', [['u2', 'node'], ['u3', 'cnt']]),
    ('NODE_DASGN', [['u2', 'node'], ['u1', 'id']]),
    ('NODE_DASGN_CURR', [['u2', 'node'], ['u1', 'id']]),
    ('NODE_GASGN', [['u2', 'node'], ['u3', 'entry']]),
    ('NODE_IASGN', [['u2', 'node'], ['u1', 'id']]),
    ('NODE_CDECL', [['u2', 'node'], ['u3', 'node']]),
    ('NODE_CVASGN', [['u2', 'node'], ['u1', 'id']]),
    ('NODE_CVDECL', [['u2', 'node'], ['u1', 'id']]),
    ('NODE_OP_ASGN1', [['u1', 'node'], ['u3', 'node'], ['u2', 'id']]),
    ('NODE_OP_ASGN2', [['u1', 'node'], ['u2', 'node'], ['u3', 'node'], ['u3', 'id'], ['u2', 'id']]),
    ('NODE_OP_ASGN_AND', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_OP_ASGN_OR', [['u1', 'node'], ['u2', 'node'], ['u3', 'id']]),
    ('NODE_CALL', [['u1', 'node'], ['u3', 'node'], ['u2', 'id']]), # explicit receiver
    ('NODE_FCALL', [['u3', 'node'], ['u2', 'id']]),                # implicit receiver
    ('NODE_VCALL', [['u2', 'id']]),                                # implicit receiver, no args
    ('NODE_SUPER', [['u3', 'node']]),
    ('NODE_ZSUPER', [['u3', 'node']]),
    ('NODE_ARRAY', [['u1', 'node'], ['u3', 'node'], ['u2', 'argc']]),
    ('NODE_ZARRAY', []),
    ('NODE_HASH', [['u1', 'node']]),
    ('NODE_RETURN', [['u1', 'node']]),
    ('NODE_YIELD', [['u1', 'node'], ['u3', 'state']]),
    ('NODE_LVAR', [['u3', 'cnt']]),
    ('NODE_DVAR', [['u1', 'id']]),
    ('NODE_GVAR', [['u3', 'entry']]),
    ('NODE_IVAR', [['u1', 'id']]),
    ('NODE_CONST', [['u1', 'id']]),
    ('NODE_CVAR', [['u1', 'id']]),
    ('NODE_NTH_REF', [['u2', 'argc']]),
    ('NODE_BACK_REF', [['u2', 'argc']]),
    ('NODE_MATCH', [['u1', 'value']]),
    ('NODE_MATCH2', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_MATCH3', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_LIT', [['u1', 'value']]),
    ('NODE_STR', [['u1', 'value']]),
    ('NODE_DSTR', []),
    ('NODE_XSTR', [['u1', 'value']]),
    ('NODE_DXSTR', []),
    ('NODE_EVSTR', [['u2', 'node']]),
    ('NODE_DREGX', []),
    ('NODE_DREGX_ONCE', []),
    ('NODE_ARGS', []),
    ('NODE_ARGSCAT', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_ARGSPUSH', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_SPLAT', [['u1', 'node']]),
    ('NODE_TO_ARY', [['u1', 'node']]),
    ('NODE_SVALUE', [['u1', 'node']]),
    ('NODE_BLOCK_ARG', [['u3', 'cnt']]),
    ('NODE_BLOCK_PASS', []),
    ('NODE_DEFN', [['u3', 'node'], ['u3', 'cnt'], ['u2', 'id']]),  # def foo(...)
    ('NODE_DEFS', [['u1', 'node'], ['u3', 'node'], ['u1', 'id']]), # def obj.foo(...)
    ('NODE_ALIAS', []),
    ('NODE_VALIAS', []),
    ('NODE_UNDEF', []),
    ('NODE_CLASS', [['u1', 'node'], ['u3', 'node'], ['u2', 'id'], ['u2', 'node']]),  # #define nd_cpath u1.node,  #define nd_super u3.node
    ('NODE_MODULE', [['u1', 'node']]),
    ('NODE_SCLASS', [['u1', 'node']]),
    ('NODE_COLON2', [['u1', 'node'], ['u2', 'id']]),
    ('NODE_COLON3', [['u2', 'id']]),
    ('NODE_CREF', []),
    ('NODE_DOT2', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_DOT3', [['u1', 'node'], ['u2', 'node']]),
    ('NODE_FLIP2', [['u1', 'node'], ['u2', 'node'], ['u3', 'cnt']]),
    ('NODE_FLIP3', [['u1', 'node'], ['u2', 'node'], ['u3', 'cnt']]),
    ('NODE_ATTRSET', []),
    ('NODE_SELF', []),
    ('NODE_NIL', []),
    ('NODE_TRUE', []),
    ('NODE_FALSE', []),
    ('NODE_DEFINED', [['u1', 'node']]),
    ('NODE_NEWLINE', [['u3', 'node']]),
    ('NODE_POSTEXE', []),
    ('NODE_ALLOCA', []),
    ('NODE_DMETHOD', []),
    ('NODE_BMETHOD', []),
    ('NODE_MEMO', []),
    ('NODE_IFUNC', []),
    ('NODE_DSYM', [['u1', 'value'], ['u2', 'id']]),
    ('NODE_ATTRASGN', [['u1', 'node'], ['u3', 'node'], ['u2', 'id']]),
    ('NODE_LAST', []),
  ]

  t_none = 0x00
  t_nil = 0x01
  t_object = 0x02
  t_class = 0x03
  t_iclass = 0x04
  t_module = 0x05
  t_float = 0x06
  t_string = 0x07
  t_regexp = 0x08
  t_array = 0x09
  t_fixnum = 0x0a
  t_hash = 0x0b
  t_struct = 0x0c
  t_bignum = 0x0d
  t_file = 0x0e
  t_true = 0x20
  t_false = 0x21
  t_data = 0x22
  t_match = 0x23
  t_symbol = 0x24
  t_node = 0x3f

  FL_USHIFT = 11

  def __init__(self, target, process, frame):
    self.frame = frame
    self.target = target or frame.GetThread().GetProcess().GetTarget()
    if target:
      self.ci = target.GetDebugger().GetCommandInterpreter()

  # === about node ==========================
  def line_num(self, node):
    if self.is_not_nil(node):
      v = node.GetChildMemberWithName("flags")
      if self.is_not_nil(v):
        return ((int(v.GetValue()) >> 19) & 0xFFF)
      else:
        return None
    else:
      return None

  def get_node_type(self, node):
    if self.is_not_nil(node):
      idx = self.get_node_type_integer(node)
      if idx:
        return map((lambda e: e[0]), self.available_children)[idx]
      else:
        return 'None'
    else:
      return 'None'

  def get_node_type_integer(self, node):
    if self.is_not_nil(node):
      v = node.GetChildMemberWithName("flags")
      if self.is_not_nil(v):
        return ((int(v.GetValue()) >> 11) & 0xFF)
      else:
        return None
    else:
      return None

  def child_node_value(self, node, node_type, key, category, filter_types, depth):
      if not filter_types and depth > 0:
          next_depth = depth - 1
      else:
          next_depth = depth
      #try:
      obj = self.get_member(self.get_member(node, key), category)
      if filter_types:
          if category == 'node':
              return self.inspect_node(obj, filter_types, next_depth)
          else:
              return None
      else:
          if category == 'value': r = self.inspect_value(obj)
          elif category == 'node': r = self.inspect_node(obj, None, next_depth)
          elif category == 'id': r = self.id2name(obj)
          elif category == 'argc': r = str(obj)
          elif category == 'entry': r = "(entry)"
          elif category == 'cnt':
              if node_type == 'NODE_LVAR' or node_type == 'NODE_LASGN' or node_type == 'NODE_BLOCK_ARG':
                  idx = self.get_member(self.get_member(node, key), category)
                  r = self.get_string(self.frame.EvaluateExpression("rb_id2name(ruby_scope.local_tbl[%s])" % idx))
              else:
                  r = str(obj)
          elif category == 'tbl': r = "(tbl)"
          elif category == 'cfunc': r = "(cfunc)"
          elif category == 'state': r = str(obj)
          else: r = '(None)'
          #except:# gdb.MemoryError, gdb.error:
          #  r = '(EREOR)'
          return r

  def inspect_node_base_value(self, node):
      if self.is_not_nil(self.get_member(node, 'flags')):
        line_number = (int(self.get_member(node, 'flags').GetValue()) >> (self.FL_USHIFT + 8)) & (2 ** 13 - 1)
      else:
        line_number = None
      fname = self.node_fname(node)
      return {'nd_file': fname, 'line_number': line_number, 'u1': {},  'u2': {}, 'u3': {}}

  def inspect_node(self, node, filter_types=None, depth=None):
      if depth == 0:
          return None
      node_type = self.get_node_type(node)
      result = self.inspect_node_base_value(node)
      result['type'] = node_type
      if filter_types and type(filter_types) != list:
          filter_types = [filter_types]
      transit = filter_types and (not (node_type in filter_types))
      if transit:
          result = []
      for key, category in self.find(node_type, self.available_children):
          if not transit:
              filter_types = None
          r = self.child_node_value(node, node_type, key, category, filter_types, depth)
          if transit:
              if r and type(r) == list:
                  result.extend(r)
              elif r:
                  result.extend([r])
          else:
              result[key][category] = r
      return result

  def node_to_json(self, node, filter_types=None, depth=None):
      return json.dumps(self.inspect_node(node, filter_types, depth))

  def to_xml(self, dic):
    def wrap_tag(name, dic):
      return "<%(name)s %(attrs)s>%(inner)s</%(name)s>" % {'name': name, 'inner': dic[name], 'attrs': dic.get('attrs', '')}
    if type(dic) == dict:
      converted_dic = {
        'type': dic.get('node', {}).get('type', ''),
        'u1': self.to_xml(dic.get('node', {}).get('u1', '')),
        'u2': self.to_xml(dic.get('node', {}).get('u2', '')),
        'u3': self.to_xml(dic.get('node', {}).get('u3', '')),
        'value': dic.get('value', '')
      }
      inner = ''
      for name in ['type', 'u1', 'u2', 'u3']:
        if converted_dic['type']:
          inner = inner + wrap_tag(name, converted_dic)

      if inner == '' and converted_dic['value'] == '':
        return ''
      else:
        return "<node value='%(value)s'>%(inner)s</node>" % {'value': converted_dic['value'], 'inner': inner}
    else:
      return str(dic)

  def get_node_by_xml(self, node, filter_types=None, depth=None):
    dic = self.inspect_node(node, filter_types=None, depth=None)
    return self.to_xml({'node': dic})

  # ===============================================

  def current_node(self):
    return self.frame.EvaluateExpression('ruby_current_node')

  def current_line(self):
    return self.line_num(self.current_node())

  def current_fname(self):
    return self.node_fname(self.frame.EvaluateExpression('ruby_current_node'))

  def node_fname(self, node):
    r = self.get_member(node, 'nd_file')
    return self.get_string(r)

  def find(self, elem, whole):
    arr = filter((lambda t: t[0] == elem), whole)
    if arr:
      return arr[0][1]
    else:
      return []

  def get_class_name(self, value):
    if self.have_valid_flags(value):
      basic = self.frame.EvaluateExpression("((struct RBasic*)(%d))" % int(value.GetValue()))
      flags = self.get_member(basic, 'flags')
      klass = self.get_member(basic, 'klass')
      if flags.GetValueAsUnsigned() & 0x3F == self.t_node:
        return '(NODE)'
      else:
        a = self.frame.EvaluateExpression("rb_class_path(%s)" % klass.GetValue())
        b = self.frame.EvaluateExpression("((struct RString*)(%d))" % int(a.GetValue()))
        c = self.get_member(b, 'ptr')
        return self.get_string(c)

  def get_ruby_object_type(self, value):
    if self.have_valid_flags(value):
      flags = self.get_member(self.cast2(value, 'struct RBasic*'), 'flags')
      return int(flags.GetValue()) & 0x3f

  def have_valid_klass(self, value):
    return self.get_ruby_object_type(value)

  types_with_klass = [t_none, t_nil, t_object, t_class, t_iclass, t_module,
      t_float, t_string, t_regexp, t_array, t_fixnum, t_hash, t_struct,
      t_bignum, t_file, t_true, t_false, t_data, t_match, t_symbol]

  def is_integer(self, value):
    v = value.GetValueAsUnsigned()
    return ((v % 2) == 1)

  def is_symbol(self, value):
    v = value.GetValueAsUnsigned()
    return ((v & 0xFF) == 0x0E)

  def is_true(self, value):
    return (value.GetValueAsUnsigned() == 2)

  def is_false(self, value):
    return (value.GetValueAsUnsigned() == 0)

  def is_nil(self, value):
    return (value.GetValueAsUnsigned() == 4)

  def is_bool(self, value):
    return (self.is_true(value) or self.is_false(value) or self.is_nil(value))

  def have_valid_flags(self, value):
    return not (self.is_bool(value) or self.is_symbol(value) or self.is_integer(value))

  def inspect_value(self, value):
      if self.have_valid_klass(value):
          klass = self.get_class_name(value)
          if klass == 'String':
              return self.inspect_string(value)
          elif klass == 'Array':
              return self.inspect_array(value)
          else:
              r = "(NA klass: %s)" % klass
              return r
      else:
          if self.is_integer(value):
              return self.inspect_integer(value)
          elif self.is_symbol(value):
              return self.inspect_symbol(value)
          elif self.is_bool(value):
              return self.inspect_bool(value)
          else:
              return "(NA not klass)"

  def inspect_string(self, value):
    flags = int(self.get_member(self.cast2(value, 'struct RBasic*'), 'flags').GetValue())
    elts_shared_flag = (flags >> 13) & 0x01
    if(elts_shared_flag == 1):
      a = self.cast2(value, 'struct RString*')
      b = self.get_member(self.get_member(a, 'aux'), 'shared')
      c = self.inspect_string(b)
      return c
    else:
      return "'%s'" % self.get_string(self.get_member(self.cast2(value, 'struct RString*'), 'ptr')).replace("'", "\\'")

  def inspect_symbol(self, value):
    inted_value = int(value.GetValue())
    return ":%s" % self.get_string(self.callc('rb_id2name', (inted_value >> 8)))

  def inspect_integer(self, value):
    return str(int(value.GetValue()) >> 1)

  def inspect_bool(self, value):
    if self.is_true(value):
      return 'true'
    elif self.is_false(value):
      return 'false'
    elif self.is_nil(value):
      return 'nil'
    else:
      return '(NA)'

  def to_arr(self, value):
      arr = self.cast2(value, 'struct RArray*')
      length = int(self.get_member(arr, 'len').GetValue())
      ptr = self.get_member(arr, 'ptr')
      func = (lambda i: self.inspect_value(ptr.GetValueForExpressionPath('[%d]' % i)))
      return map(func, range(length))

  def inspect_array(self, value):
      return '[' + ', '.join(self.to_arr(value)) + ']'

  def instance_variables(self, obj):
      iv_list =  self.cast2(
              self.frame.EvaluateExpression('rb_obj_instance_variables(%s)' % obj.GetValue()),
              'struct RArray*')

      length = int(self.get_member(iv_list, 'len').GetValue())
      iv_ptr = self.get_member(iv_list, 'ptr')

      dic = {}
      for i in range(length):
          iv_name = iv_ptr.GetValueForExpressionPath('[%d]' % i)
          dic[iv_name] = self.frame.EvaluateExpression('rb_obj_ivar_get(%s, %s)' % (obj.GetValue(), iv_name.GetValue()))

      return dic

  def enhance_method_missing(self):
    new_bp = self.target.BreakpointCreateByName("rb_method_missing")
    res = lldb.SBCommandReturnObject()
    self.ci.HandleCommand("breakpoint command add -o 'helper.enhance_method_missing_handler(debugger, frame)' -s python %d" % new_bp.GetID(),  res)

  def observe_call(self, klass_name):
    new_bp = self.target.BreakpointCreateByName("rb_call")
    res = lldb.SBCommandReturnObject()
    self.ci.HandleCommand("breakpoint command add -o 'helper.observe_call_handler(debugger, frame, \"%s\")' -s python %d" % (klass_name, new_bp.GetID()),  res)

  def observe_load(self):
    def handler(event):
      print ">>[rb_load_file] " + self.get_string(self.frame.EvaluateExpression("fname"))
      self.process.Continue()
    new_bp = target.BreakpointCreateByName("rb_load_file")
    res = lldb.SBCommandReturnObject()
    self.ci.HandleCommand("breakpoint command add -o 'handler()' -s python %d" % new_bp.GetID(),  res)

  def get_backtrace(self, origin_frame=None, only_top=False):
    if origin_frame:
      results = []
    else:
      origin_frame = self.frame.EvaluateExpression("ruby_frame")
      last_func = self.get_member(origin_frame, 'last_func')
      method_name = (last_func and self.id2name(last_func)) or ''
      results = [(self.current_fname(), self.current_line(), method_name)]
    if only_top:
      return results
    prev = self.get_member(origin_frame, 'prev')
    if self.is_not_nil(prev):
      node = self.get_member(origin_frame, 'node')
      last_func = self.get_member(prev, 'last_func')
      method_name = (self.is_not_nil(last_func) and self.id2name(last_func)) or ''
      results.extend([(self.node_fname(node), self.line_num(node), method_name)])
      results.extend(self.get_backtrace(prev))
    return results

  def print_backtrace(self):
    backtraces = self.get_backtrace()
    for (fname, line_num, method_name) in backtraces:
      if fname and line_num:
        if method_name:
          method_name_ = 'in `%s`' % method_name
        else:
          method_name_ = ''
        print "%s:%s:%s" % (fname, line_num, method_name_)

  def get_func_name(self, origin_frame=None):
    top_trace = self.get_backtrace(origin_frame, True)
    if len(top_trace) == 0:
      return None
    else:
      return top_trace[0][-1]

  # == more abstract
  def callc(self, method_name, args):
    cmd = "%(method_name)s(%(args)s)" % {'method_name': method_name, 'args': str(args)}
    return self.frame.EvaluateExpression(cmd)

  def cast(self, value, typ, pointer=False):
    type_ = self.target.FindTypes(typ).GetTypeAtIndex(0)
    #type_ = self.target.FindFirstType(typ)
    if pointer:
      type_ = type_.GetPointerType()
    return value.Cast(type_)

  def cast2(self, value, typ_string):
    return self.frame.EvaluateExpression("((%s)(%d))" % (typ_string, int(value.GetValue())))

  def parse(self, gdb_string):
    return self.frame.EvaluateExpression(gdb_string)

  def id2name(self, id_):
    return self.get_string(self.frame.EvaluateExpression("rb_id2name(%s)" % str(id_.GetValue())))

  def is_not_nil(self, value):
    return value and value.GetValue() and value.GetValue() != '0'

  def get_member(self, obj, name):
    for x in obj:
      if x.GetName() == name:
        return x
    return None

  def get_string(self, value):
      if value:
          s = value.GetSummary()
          if s:
            return s.replace('"', '')
          else:
            return ''
      else:
          return ''

  def find_all_literals(self, node_dic):
    if ('type' in node_dic) and node_dic['type'] == 'NODE_LIT':
      if node_dic['u1'] and node_dic['u1']['value']:
        return [node_dic['u1']['value']]
      else:
        return []
    else:
      result = []
      for _, v in node_dic.items():
        if isinstance(v, dict):
          result += self.find_all_literals(v)
      return result

  # get current pairs of local variable and the value.
  def local_vars(self):
    dic = {}
    i = 1
    while True:
      local_tbl = self.frame.EvaluateExpression('ruby_scope->local_tbl')
      local_vars = self.frame.EvaluateExpression('ruby_scope->local_vars')
      k = local_tbl.GetValueForExpressionPath("[%d]" % i)
      v = local_vars.GetValueForExpressionPath("[%d]" % (i - 1))
      if not self.is_not_nil(k):
          break
      dic[self.id2name(k)] = v
      i += 1
    return dic
