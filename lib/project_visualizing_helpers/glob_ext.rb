# -*- encoding: utf-8 -*-

module ProjectVisualizingHelpers
  class GlobExt
    def initialize(options={})
      options.assert_valid_keys(:only_text, :grep)

      @only_text = options[:only_text]
      @pattern = options[:grep]

      @dir_info_cache = {}
    end

    def glob(glob_pattern, &block)
      path_and_infos = []

      Dir[glob_pattern].each do |path|
        next if @only_text && File.file?(path) && !is_text?(path)
        raise "path: `#{path.inspect}` have double quotation in file name." if path.include?('"')

        path_and_info = [path] + dir_info(path)
        path_and_infos << path_and_info
        if block_given?
          block.call(path_and_info)
        end
      end

      path_and_infos
    end

    # RETURN: e.g. "text/plain; charset=utf-8"
    def self.mime(path)
      FileMagic.open(FileMagic::MAGIC_MIME) do |magic|
        return magic.file(path)
      end
    end

    def is_text?(path)
      raise "The path `#{path}` is directory" if File.directory?(path)

      GlobExt.mime(path) =~ /^text\//
    end

    # return value :: [エントリ数, 行数, バイト数, パターンマッチ数]
    def dir_info(path)
      @dir_info_cache[path] ||
      @dir_info_cache[path] = if File.directory?(path)
                                matrix = Dir["#{path}/*"].map{|child| dir_info(child) }
                                matrix.present? ? matrix.transpose.map(&:sum_) : [0, 0, 0, 0]
                              elsif !is_text?(path) and @only_text
                                [0, 0, 0, 0]
                              else
                                STDERR.puts "WARNING: The path `#{path}` is binary, then the size is counted to 0" unless is_text?(path)

                                if @pattern
                                  match_count = File.read(path).scan(@pattern).size
                                else
                                  match_count = 0
                                end

                                lnum = is_text?(path) ? File.read(path).split("\n").size : 0

                                [1, lnum, File.size(path), match_count]
                              end
    end
  end
end
