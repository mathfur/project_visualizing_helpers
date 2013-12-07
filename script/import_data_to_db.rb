#!/usr/bin/env ruby
# encoding: utf-8

$: << (File.dirname(__FILE__) + "/..")

require 'getoptlong'
require "./lib/project_visualizing_helpers"

usage = <<EOS
Usage: import_data_to_db table_name file
-h --help    Display help.
-l --label   Specify header names. For example, --label=id,name,age

Example:
  import_data_to_db access_logs logs.txt
  import_data_to_db users users.log
EOS

opts = GetoptLong.new(
  ['--help',  '-h', GetoptLong::NO_ARGUMENT],
  ['--label', '-l', GetoptLong::REQUIRED_ARGUMENT]
)

headers = nil

begin
  opts.each do |opt, arg|
    case opt
    when '--help'; STDERR.puts usage; exit
    when '--label'
      headers = arg.split(',').reject{|v| v.blank? }
      raise "--label has to have some arguments" if headers.blank?
    end
  end
rescue StandardError => e
  STDERR.puts "[ERROR] wrong option" + e.inspect
  exit
end


table_name = ARGV.shift

unless %{access_logs users}.include?(table_name)
  STDERR.puts "[ERROR] `#{table_name}` is wrong table name"
  STDERR.puts usage
  exit
end

lines = []

while line = gets
  line = line.gsub(/\n$/, '').split(',')
  if headers
    lines << line
  else
    headers = line
  end
end

ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}"

lines.each do |line|
  header_str = headers.map{|h| '`' + h + '`' }.join(', ')
  line_str = line.map{|v| "'" + v + "'" }.join(', ')

  sql = "INSERT INTO #{table_name} (#{header_str}) VALUES (#{line_str})"
  puts sql
  ActiveRecord::Base.connection.execute sql
end
