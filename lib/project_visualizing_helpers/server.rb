# encoding: utf-8

module ProjectVisualizingHelpers
  class Server < Sinatra::Base
    set :root, BASE_DIR

    logger = File.new("#{BASE_DIR}/log/app.log", 'a+')
    use Rack::CommonLogger, logger

    get '/' do
      haml :index
    end

    get '/schedules' do
      [
        "complete,start,end,title",
        "x,9/28 10:00,9/28 13:00,準備",
        "x,9/28 13:00,9/28 14:00,タスクA"
      ].join("\n")
    end

    get '/access_logs' do
      "index,time,user,byte,req\n" +
        File.read("#{BASE_DIR}/tmp/access_logs.log")
    end

    get '/users' do
      "index,name,age,sex,prefecture\n" +
        File.read("#{BASE_DIR}/tmp/users.log")
    end

    @@mutex = Mutex.new
    helpers do
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
