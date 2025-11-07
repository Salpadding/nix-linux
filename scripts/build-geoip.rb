#!/usr/bin/env ruby

require 'open-uri'
require 'erb'
require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on("-t", "--template TEMPLATE", "template file") do |v|
    options[:template] = v
  end

  opts.on("-s", "--source SOURCE", "apnic source file") do |v|
    options[:source] = v
  end

  opts.on("-o", "--output OUTPUT", "output file") do |v|
    options[:output] = v
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!

puts "open file #{options[:source]}"
source = File.open options[:source]

cn_cidr_list = []

source.each_line do |line|
  next if line.start_with?('#') || line.strip.empty?
  fields = line.split('|')
  next unless fields.size >= 5

  registry, cc, type, start, value = fields[0, 5]
  next unless cc == 'CN' && type == 'ipv4'

  value_i = value.to_i
  prefix = 32 - Math.log2(value_i)
  cn_cidr_list += ["#{start}/#{prefix.to_i}"]
end

puts "load template #{options[:template]}"
template = File.read options[:template]
erb = ERB.new template
result = erb.result binding

puts "write to #{options[:output]}"
File.write options[:output], result