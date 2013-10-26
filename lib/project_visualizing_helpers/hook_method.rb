# encoding: utf-8

class Module
  def alias_method_chain(target, feature)
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    yield(aliased_target, punctuation) if block_given?

    with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
    without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

    alias_method without_method, target
    alias_method target, with_method

    case
    when public_method_defined?(without_method)
      public target
    when protected_method_defined?(without_method)
      protected target
    when private_method_defined?(without_method)
      private target
    end
  end
end

class Class
  def all_instance_methods
    methods = self.public_instance_methods + self.private_instance_methods

    if (superclass = self.superclass)
      methods -= (superclass.public_instance_methods + superclass.private_instance_methods)
    end

    methods
  end

  def all_class_methods
    methods = self.public_methods + self.private_methods

    if (superclass = self.superclass)
      methods -= (superclass.public_methods + superclass.private_methods)
    end

    methods
  end
end

module ProjectVisualizingHelpers
  class HookMethod
    def self.hook(klass, file_pointer)
      klass.all_instance_methods.each do |method|
        klass.class_eval do
          method_without_suffix, suffix = HookMethod.split_suffix(method)

          define_method "#{method_without_suffix}_with_function_call_logging#{suffix}" do |*args|
            file_pointer.puts %Q!in,#{method},#{args.map(&:inspect).join(',')}!
            self.send("#{method_without_suffix}_without_function_call_logging#{suffix}", *args)
            file_pointer.puts "out,#{method}"
          end

          alias_method_chain method, :function_call_logging
        end
      end

      klass.all_class_methods.each do |class_method|
        klass.class_eval do
          class << self; self; end.class_eval do
            method_without_suffix, suffix = HookMethod.split_suffix(class_method)

            define_method "#{method_without_suffix}_with_function_call_logging#{suffix}" do |*args|
              file_pointer.puts %Q!in,#{class_method},#{args.map(&:inspect).join(',')}!
              self.send("#{method_without_suffix}_without_function_call_logging#{suffix}", *args)
              file_pointer.puts "out,#{class_method}"
            end

            alias_method_chain class_method, :function_call_logging
          end
        end
      end
    end

    def self.split_suffix(method)
      method.to_s.match(/\A(.*?)([\?=!])?\Z/).to_a[1..-1]
    end
  end
end
