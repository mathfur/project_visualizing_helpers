$:.unshift(File.dirname(__FILE__))

require "csv"
require "erb"
require "tempfile"
require "filemagic"
require "sinatra"
require 'active_record'
#require "sinatra/activerecord/rake"

require "base_extension"

require "project_visualizing_helpers/base"
require "project_visualizing_helpers/mysqllog2csv"
require "project_visualizing_helpers/railroad2csv"
require "project_visualizing_helpers/apache2csv"
require "project_visualizing_helpers/railslog2csv"
require "project_visualizing_helpers/graph"
require "project_visualizing_helpers/db_schema2csv"
require "project_visualizing_helpers/class_diagram2instance_diagram"
require "project_visualizing_helpers/hook_method"
require "project_visualizing_helpers/glob_ext"
require "project_visualizing_helpers/include2csv"
require "project_visualizing_helpers/filter_json"
require "project_visualizing_helpers/models"

BASE_DIR = "#{File.dirname(__FILE__)}/.."
TARGET_DIR = Dir.pwd

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection('main')
