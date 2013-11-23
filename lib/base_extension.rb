# -*- encoding: utf-8 -*-

class Object
  def tee(options={},  &block)
    label = options[:label] || options[:l]
    method_name = options[:method] || options[:m] || :inspect

    STDERR.puts ">> #{label}"

    if block_given?
      STDERR.puts block.call(self)
    else
      STDERR.puts (method_name == :nothing) ? self : self.send(method_name)
    end

    STDERR.puts ">>"

    self
  end

  def try(*args)
    (self == nil) ? nil : self.send(*args)
  end

  def present?
    !self.blank?
  end

  def blank?
    [nil, false, [], '', {}].include?(self)
  end

  def present_or(obj)
    self.present? ? self : obj
  end
end

class String
  def underscore
    self.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

class Array
  def sum
    case self.length
    when 0
      nil
    when 1
      self[0]
    else
      self[1..-1].inject(self[0]){|s, e| s + e }
    end
  end

  def adjacent_pairs
    if self.length <= 1
      []
    else
      (self[0..self.length-2]).zip(self[1..self.length-1])
    end
  end
end

class Module
  # result contain Class too.
  def fr_modules
    self.constants.map{|m| self.const_get(m) }.select{|m| m.class.ancestors.map(&:to_s).include?("Module") }
  end

  def fr_classes
    self.constants.map{|m| self.const_get(m) }.select{|m| m.class == Class }
  end

  # RETURN :: [[Class], [Module]]
  def child_classes(arrowed_depth)
    if arrowed_depth == 0
      [[], []]
    else
      matrix = self.fr_modules.map{|child| child.child_classes(arrowed_depth-1) }

      if matrix.present?
        classes, modules = matrix.transpose.map(&:sum)
      else
        classes = []
        modules = []
      end

      [(classes + self.fr_classes).uniq, (modules + self.fr_modules).uniq]
    end
  end
end

module Enumerable
  def break(&block)
    oks = []
    remainder = []
    breaked = false

    self.each do |e|
      if breaked
        remainder << e
      else
        r = block.call(e)
        if !r
          breaked = true
          remainder << e
        else
          oks << e
        end
      end
    end

    [oks, remainder]
  end
end

class Hash
  def assert_valid_keys(*valid_keys)
    valid_keys.flatten!
    each_key do |k|
      raise ArgumentError.new("Unknown key: #{k}") unless valid_keys.include?(k)
    end
  end
end

class Proc
  def c
    self.curry
  end
end
