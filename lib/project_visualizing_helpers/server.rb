# encoding: utf-8

module ProjectVisualizingHelpers
  class Server < Sinatra::Base
    set :root, BASE_DIR

    logger = File.new("#{BASE_DIR}/log/app.log", 'a+')
    use Rack::CommonLogger, logger

    get '/' do
      haml :index
    end

    get '/field_types' do
      flatten_field_types = {}
      field_type_each_table = YAML.load_file('config/models.yml')

      field_type_each_table.each do |name, defs|
        defs.each do |k, v|
          flatten_field_types[k] = v
        end
      end

      {id: 'number', count: 'number'}.merge(flatten_field_types).to_json
    end

    get '/access_logs' do
      columns = params.delete('group')

      filters = params.inject({}) do |h, (k, v)|
                  table = belong_table(k)
                  h[table] ||= {}
                  h[table][k] = v
                  h
                end

      group_columns = columns.map{|k| "#{belong_table(k)}.#{k}" }

      (columns + ['count']).join(',') + "\n" +
        AccessLog.joins(:user).where(filters).group(group_columns).count.map{|log, c| "#{log.join(',')},#{c}" }.join("\n")
    end

    get '/tree' do
      haml :tree
    end

    get '/tree_data' do
      {
        name: "point#{rand(10)}",
        klass: "Point",
        instance_variables: [
          {name: "x", value: 10},
          {name: "y", value: 20},
          {name: "append_object", klass: 'Append', instance_variables: [
            {name: "foo", value: 'aaa'}]}
        ]
      }.to_json
    end

    @@mutex = Mutex.new
    helpers do
      def belong_table(col)
        access_log_columns = AccessLog.column_names
        user_columns = User.column_names

        if access_log_columns.include?(col)
          "access_logs"
        elsif user_columns.include?(col)
          "users"
        else
          raise "`#{col}` is wrong column name"
        end
      end

      def execute_script(cmd)
        result = nil

        @@mutex.synchronize do
          Dir.chdir(TARGET_DIR) do
            statement = "ruby #{BASE_DIR}/script/#{cmd}"
            STDERR.puts "run '#{statement}' ..."
            STDERR.puts (result = `#{statement}`)
            STDERR.puts "========="
          end
        end

        result
      end
    end
  end
end

ProjectVisualizingHelpers::Server.run! :host => 'localhost', :port => 9090
