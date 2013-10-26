# -*- encoding: utf-8 -*-

require "spec_helper"

describe ProjectVisualizingHelpers::GlobExt do
  describe '#result' do
    before do
      @dir = "#{BASE_DIR}/tmp/testdata"
      Dir.mkdir(@dir) unless Dir.exist?(@dir)
    end

    specify do
      result = ProjectVisualizingHelpers::GlobExt.new.glob("#{@dir}/**/*")
      result.sort.should == [
        ["#{@dir}/file1",     1, 2, 8,  0],
        ["#{@dir}/dir/file2", 1, 1, 5,  0],
        ["#{@dir}/dir/file3", 1, 0, 3,  0],
        ["#{@dir}/dir",       2, 1, 8,  0],
      ].sort
    end

    specify do
      result = ProjectVisualizingHelpers::GlobExt.new(:grep => 'ij').glob("#{@dir}/**/*")
      result.sort.should == [
        ["#{@dir}/file1",     1, 2, 8,  0],
        ["#{@dir}/dir/file2", 1, 1, 5,  1],
        ["#{@dir}/dir/file3", 1, 0, 3,  0],
        ["#{@dir}/dir",       2, 1, 8,  1],
      ].sort
    end

    specify do
      result = ProjectVisualizingHelpers::GlobExt.new(:only_text => true).glob("#{@dir}/**/*")
      result.sort.should == [
        ["#{@dir}/file1",     1, 2, 8,  0],
        ["#{@dir}/dir/file2", 1, 1, 5,  0],
        ["#{@dir}/dir",       1, 1, 5,  0],
      ].sort
    end
  end
end
