#!/usr/bin/env ruby
require 'optparse'
require 'yaml'
require 'json'
require 'uri'
require "net/http"

options = {
  dir: 'conf/mihomo',
  profile: 'router'
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on("-d", "--dir DIRECTORY", "Directory to store mihomo configurations") do |v|
    options[:dir] = v
  end

  opts.on("-x", "--proxy PROXY", "Http proxy server address") do |v|
    options[:proxy] = v
  end


  opts.on("-p", "--profile PROFILE", "Profile name") do |v|
    options[:profile] = v
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!


class ClashConfBuilder
  def initialize(options:)
    @options = options
  end

  def merge_rules
    rules_dir = File.join(@options[:dir].to_s, 'rules')
    if !Dir.exist?(rules_dir)
      return []
    end

    Dir.children(rules_dir)
    .sort.map { |name| File.join(rules_dir, name) }
    .select { |p| File.file?(p) }
    .map { |f| YAML.load_file f}
    .map { 
      |data| data["rules"]
    }.flatten
  end

  def profile_root(profile)
    File.join(@options[:dir], "profiles", profile)
  end

  def load_proxies(profile)
      profile_root = self.profile_root(profile)
      providers = JSON.load_file File.join(profile_root, "providers.json")

      providers.map do  |provider| 
        uri = URI provider["url"]
        data = YAML.load Net::HTTP.get(uri)
        proxies = data['proxies'] || []
        proxies.each do |proxy|
          proxy['name'] = provider['prefix'] + proxy['name']
        end
        proxies
      end.flatten
  end

  def gen_conf(profile)
      profile_root = self.profile_root(profile)

      load_yml = ->(name) do
        path = File.join(profile_root, "#{name}.yaml")
        return nil unless File.exist?(path)
        YAML.load_file(path)
      end

      base = load_yml.call "main"
      base['dns'] ||= {}
      base['dns'].merge! load_yml.call('fake-ip-filter') || {}

      base['rules'] = self.merge_rules
      proxies = load_proxies(profile)
      proxy_groups = load_yml.call('proxy-groups') 
      proxy_groups['proxy-groups'].each do |group|
        group['proxies'] ||= []
        group['proxies'] += proxies.map { |x| x['name'] }
      end

      base['proxies'] = proxies

      base.merge! proxy_groups
  end
end

builder = ClashConfBuilder.new(options: options)
conf = builder.gen_conf(options[:profile])
File.write(File.join(options[:dir], "#{options[:profile]}.yaml"), conf.to_yaml)

puts "ok"