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

BASE_DIR = "#{File.dirname(__FILE__)}/.."
CONFIG_DIR = "#{BASE_DIR}/config"
TARGET_DIR = Dir.pwd

ActiveRecord::Base.configurations = YAML.load_file("#{CONFIG_DIR}/database.yml")
ActiveRecord::Base.establish_connection('main')

raise "Create config/relation.yml, and write relation information to it." unless File.file?("#{CONFIG_DIR}/relation.yml")
YAML.load_file("#{CONFIG_DIR}/relation.yml").each do |definition|
  definition = definition.symbolize_keys

  eval(<<-EOS)
  class #{definition[:from]} < ActiveRecord::Base
    belongs_to :#{definition[:name]}, :class_name => "#{definition[:to]}", :foreign_key => "#{definition[:foreign_key]}", :primary_key => "#{definition[:primary_key]}"
  end
  EOS
end
