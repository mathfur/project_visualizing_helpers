# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::DbSchema2CSV do
  describe '#result' do
    def db_schema2csv(input)
      ProjectVisualizingHelpers::DbSchema2CSV.new(input).result
    end

    specify do
      expect = [
        ["users", "name", "string", "50"],
        ["users", "age", "integer", nil],
        ["blogs", "title", "string", nil],
        ["blogs", "created_at", "timestamp", nil]
      ]

      db_schema2csv(<<-EOS).should == expect
ActiveRecord::Schema.define(:version => 1) do

  create_table :users do |t|
    t.column :name, :string, :limit => 50
    t.column :age, :integer
  end

  create_table :blogs, :force => true do |t|
    t.column :title, :string
    t.column :created_at, :timestamp
  end
end
      EOS
    end

    specify 'column definition before table definition should raise error' do
      proc{ db_schema2csv(<<-EOS) }.should raise_error
    t.column :name, :string, :limit => 50
  create_table :users do |t|
      EOS
    end
  end

  describe '.headers' do
    specify { ProjectVisualizingHelpers::DbSchema2CSV.new('').headers.should == %w{table column type limit} }
  end
end
