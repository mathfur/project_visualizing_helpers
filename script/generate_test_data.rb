#!/usr/bin/env ruby
# encoding: utf-8

require 'getoptlong'

usage = <<EOS
Usage: generate_test_data mode [options]
-h --help    Display help.
-n --number  A number of output log line. (access_log mode only)

mode: user or access_log
EOS

opts = GetoptLong.new(
  ['--help',   '-h', GetoptLong::NO_ARGUMENT],
  ['--number', '-n', GetoptLong::REQUIRED_ARGUMENT]
)

number = nil

begin
  opts.each do |opt, arg|
    case opt
    when '--help'; puts usage; exit
    when '--number'; number = arg.to_i
    end
  end
rescue StandardError => e
  puts "[ERROR] wrong option" + e.inspect
  puts usage
  exit
end

class Array
  def rand
    self[Kernel.rand(self.size)]
  end
end

#------------------------
def dist(a)
  n = 10
  r = ((1..n).to_a.inject(0.0){|s, _| s + rand } - (n.to_f / 2)) / n
  10 * a * r
end

# === user

def age_rand(c)
  (c + dist(10)).floor
end

def sex_rand
  ['male', 'female'][rand(2)]
end

def user_names
  %w{Sato Sato Sato Sato Suzuki Suzuki Suzuki Takahashi Takahashi Tanaka Tanaka Ito Ito
    Yamamoto Watanabe Nakamura Kobayashi Kato Yoshida Yamada}.sort.uniq
end

def name_rand
  %w{Sato Sato Sato Sato Suzuki Suzuki Suzuki Takahashi Takahashi Tanaka Tanaka Ito Ito
    Yamamoto Watanabe Nakamura Kobayashi Kato Yoshida Yamada}.rand
end

def prefecture_rand
  %w{hokkaido saitama chiba tokyo tokyo tokyo tokyo kanagawa kanagawa kyoto osaka okinawa}.rand
end

def users_rand
  user_names.enum_for(:each_with_index).map do |name, i|
    case sex_rand
    when 'male'
      "#{i},#{name},#{age_rand(40)},male,#{prefecture_rand}"
    when 'female'
      "#{i},#{name},#{age_rand(35)},female,#{prefecture_rand}"
    end
  end
end

# === access_log

def byte_rand(c)
  (c + dist(100)).floor
end

def time_rand
  Time.at(
    (Time.now.to_i + dist(10000)).floor
  ).strftime('%Y-%m-%d %H:%M:%S')
end

def query_url
  path1 = %w{blogs blogs users groups}.rand
  path2 = %w{index index index show edit}.rand
  "GET /#{path1}/#{path2}"
end

def access_logs_rand(num)
  (1..num).to_a.map do |i|
    "#{i},#{time_rand},#{name_rand},#{byte_rand(1000)},#{query_url}"
  end
end

log_type = ARGV[0]

unless log_type
  puts "log_type is required."
  puts usage
  exit
end

case log_type
when 'user'
  if number
    puts "[ERROR] user mode can not use --number value."
    puts usage
    exit
  end

  puts users_rand
when 'access_log'
  if !number or number <= 0
    puts "[ERROR] --number value has to be positive integer."
    puts usage
    exit
  end

  puts access_logs_rand(number)
else
  puts "wrong type: `#{log_type}`"
  puts usage
  exit
end
