# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class Include2CSV
    def initialize(base=nil)
      @base = base
    end

    def to_csv
      self.result.map(&:to_csv).join
    end

    def result
      if @base
        get_parent_child_pairs(@base)
      else
        all_classes.map{|klass| get_parent_child_pairs(klass) }.sum_ || []
      end
    end

    # RETURN :: [String]
    def get_parent_child_pairs(klass)
      if (superclass = klass.superclass)
        superclass_index = klass.ancestors.index(superclass)
        klass.ancestors[0 .. superclass_index].map{|mod| mod.class == Class ? mod.to_s : "i#{mod}" }.adjacent_pairs
      else
        []
      end
    end

    # RETURN :: [Class]
    def all_classes
      previous_size = 0
      classes = nil

      max_loop = 10
      (1..max_loop).to_a.each do |depth|
        classes, _ = Object.child_classes(depth)
        print "(#{depth}:#{classes.size})" if $DEBUG

        if previous_size == classes.size
          break
        else
          previous_size = classes.size
        end

        if depth == max_loop - 1
          raise "All_modules can not be fixed by loop `#{max_loop}`."
        end
      end

      classes
    end
  end
end
