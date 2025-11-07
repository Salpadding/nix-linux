#!/usr/bin/env ruby
require 'optparse'

options = {
  owner: 'felixonmars',
  repo: 'dnsmasq-china-list',
  branch: 'master',
  proxy: '',
  dir: 'conf/dnsmasq/dns',
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on("-d", "--dir DIRECTORY", "Directory to store DNS files, default: #{options[:dir]}") do |v|
    options[:dir] = v
  end

  opts.on("-x", "--proxy PROXY", "Http proxy server address") do |v|
    options[:proxy] = v
  end

  opts.on("-k", "--token TOKEN", "Github token") do |v|
    options[:github_token] = v
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

class ChinaDns
  def initialize(options:)
    @options = options
    @curl_headers = "-H 'Authorization:token #{options[:github_token]}' -H 'Accept:application/vnd.github.v3+json' "
    if !options[:proxy].to_s.empty?
      @curl_headers += " -x '#{options[:proxy]}' "
    end
  end

  def fetch_sha(file)
    url = "https://api.github.com/repos/#{@options[:owner]}/#{@options[:repo]}/contents/#{file}"
    cmd = "curl -s #{@curl_headers} #{url} | jq -r .sha"
    puts cmd
    `#{cmd}`.strip
  end

  def download(file)
    full_path = self.full_path(file)
    puts "start download #{file}"
    url = "https://raw.githubusercontent.com/#{@options[:owner]}/#{@options[:repo]}/#{@options[:branch]}/#{file}" 
    cmd = "curl #{@curl_headers} -s -o #{full_path} '#{url}'"
    puts cmd
    system cmd
    `sed -i 's/114.114.114.114/223.5.5.5/' #{full_path}`
  end

  def full_path(file)
    File.join(@options[:dir], file)
  end

  def update(file)
    full_path = self.full_path(file)
    should_download = false
    if !File.exist?(full_path) || !File.exist?("#{full_path}.hash")
      puts "#{full_path} not exists download it"
      should_download = true
    else
      cur_sha = File.read("#{full_path}.hash").strip
      sha = fetch_sha file
      should_download = (sha != cur_sha)
      puts "#{file} fetched sha = #{sha} current sha = #{cur_sha}"
    end

    if should_download
      download file
      File.write("#{full_path}.hash", fetch_sha(file))
    end
  end

end

`mkdir -p #{options[:dir]}`
china_dns = ChinaDns.new(options: options)
dns_files = ['accelerated-domains.china.conf']

dns_files.each do |file|
  china_dns.update(file)
end

