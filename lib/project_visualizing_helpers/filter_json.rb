require "json"
require "pp"

module ProjectVisualizingHelpers
  class FilterJSON
    def initialize(json)
      @json = json
      pp @json
    end

    def default_result(obj)
      obj.slice('nd_file', 'line_number')
    end

    # node_const?['HOGE', obj] <=> objがHOGE定数を持つ
    def node_const?
      Proc.new do |const_name, obj|
        if obj["type"] == "NODE_CONST"
          if ((obj || {})["u1"] || {})["id"] == const_name
            default_result(obj).merge('const_name' => const_name)
          end
        end
      end
    end

    # node_call?[receiver_proc, args_proc, 'now', obj]
    #   <=> receiver_procを満たすオブジェクトに対して'now'が送信されていて、
    #       かつその時の引数がargs_procを満たす
    def node_call?
      Proc.new do |receiver_proc, args_proc, method_name, obj|
        obj ||= {}
        if %w{NODE_CALL NODE_FCALL NODE_VCALL}.include?(obj['type'])
          if (obj["u2"]["id"] == method_name)
            case obj['type']
            when 'NODE_CALL'
              if receiver_proc[(obj["u1"] || {})["node"]] && args_proc[(obj["u3"] || {})["node"]]
                default_result(obj).merge('method_name' => method_name)
              end
            when 'NODE_FCALL'
              if args_proc[(obj["u3"] || {})["node"]]
                default_result(obj).merge('method_name' => method_name)
              end
            when 'NODE_VCALL'
                default_result(obj).merge('method_name' => method_name)
            else
              raise
            end
          end
        end
      end
    end

    def self.traverse(hash, pr)
      if hash.kind_of?(Hash)
        [pr[v]].compact + FilterJSON.traverse(v, procs)
      else
        []
      end
    end

    def traverse(&block)
      FilterJSON.traverse(@json, block.to_proc)
    end
  end
end
