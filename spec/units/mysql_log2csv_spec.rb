# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::MySQLLog2CSV do
  describe '#initialize' do
    specify do
      ProjectVisualizingHelpers::MySQLLog2CSV.new('').result.should == []
    end

    specify do
      ProjectVisualizingHelpers::MySQLLog2CSV.new(<<-EOS).result(:time, :argument).should == [["14:14:45", "root@localhost on"]]
/foo/bar/sql/mysqld, Version: 5.1.66-log (Source distribution). started with:
Tcp port: 13000  Unix socket: /foo/bar/mysql/mysql-5.1.66/mysql-test/var/tmp/mysqld.1.sock
Time               Id Command   Argument
121116 14:14:45     1 Connect   root@localhost on
      EOS
    end

    specify do
      expected = [
        "14:14:45,root@localhost on",
        "14:14:45,SHOW SLAVE STATUS",
        "14:15:19,call mtr.check_testcase()",
        "14:15:19,",
        "14:15:19,root@localhost on test",
        "14:15:19,select 1",
        "14:15:19,",
        "14:15:19,root@localhost on",
        "14:15:19,set SQL_LOG_BIN=0",
        "14:15:19,set debug=\"\"",
        "14:15:19,use mtr",
        "14:15:19," + [
          "create temporary table error_log (",
          "row int auto_increment primary key,",
          "suspicious int default 1,",
          "file_name varchar(255),",
          "line varchar(1024) default null",
          ") engine=myisam"].join("\n"),
        "14:15:19," + [
          "load data infile '/Users/foo/src/mysql/mysql-5.1.66/mysql-test/var/log/mysqld.1.err.warnings' into table error_log",
          "fields terminated by 'xykls37' escaped by ''",
          "  ignore 1 lines",
          "(line)",
          "set file_name='/Users/foo/src/mysql/mysql-5.1.66/mysql-test/var/log/mysqld.1.err'"].join("\n"),
        "14:15:19,call mtr.check_warnings(@result)",
        "14:15:19,select @result = 0",
        "14:15:19,",
        "14:15:19,root@localhost on",
        "14:16:46,root@localhost on",
        "14:16:46,SHOW SLAVE STATUS"
      ]
      ProjectVisualizingHelpers::MySQLLog2CSV.new(<<-EOS).result(:time, :argument).map{|e| e.join(',') }.should == expected
/foo/bar/sql/mysqld, Version: 5.1.66-log (Source distribution). started with:
Tcp port: 13000  Unix socket: /Users/foo/src/mysql/mysql-5.1.66/mysql-test/var/tmp/mysqld.1.sock
Time                 Id Command    Argument
121116 14:14:45     1 Connect   root@localhost on
                    1 Query     SHOW SLAVE STATUS
121116 14:15:19     1 Query     call mtr.check_testcase()
                    1 Quit
                    2 Connect   root@localhost on test
                    2 Query     select 1
                    2 Quit
                    3 Connect   root@localhost on
                    3 Query     set SQL_LOG_BIN=0
                    3 Query     set debug=""
                    3 Query     use mtr
                    3 Query     create temporary table error_log (
row int auto_increment primary key,
suspicious int default 1,
file_name varchar(255),
line varchar(1024) default null
) engine=myisam
                    3 Query     load data infile '/Users/foo/src/mysql/mysql-5.1.66/mysql-test/var/log/mysqld.1.err.warnings' into table error_log
fields terminated by 'xykls37' escaped by ''
  ignore 1 lines
(line)
set file_name='/Users/foo/src/mysql/mysql-5.1.66/mysql-test/var/log/mysqld.1.err'
                    3 Query     call mtr.check_warnings(@result)
                    3 Query     select @result = 0
                    3 Quit
                    4 Connect   root@localhost on
Time                 Id Command    Argument
121116 14:16:46     1 Connect   root@localhost on
                    1 Query     SHOW SLAVE STATUS
EOS

    end
  end
end
