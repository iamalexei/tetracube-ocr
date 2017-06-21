#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

options = {}

opt_parse = OptionParser.new do |opts|
	opts.banner = "Usage: tetracube-ocr.rb [options]"
	opts.on('-f', '--file FILE', "Path to your book") do |book|
		options[:book] = book
	end
	opts.on('-l', '--lang LANG', "Language") do |lang|
		options[:lang] = lang
	end
	opts.on('-h', '--help', "Display this help") do
		puts opts
		exit
	end
end

opt_parse.parse!

path = options[:book]
lang = options[:lang]

class Book
	
	attr_accessor :path, :lang

	def initialize(path, lang)
		@path = path
		@lang = lang
		@ext = File.extname(@path).downcase
		@file_name = File.basename(@path, ".*")
		@temp_dir = "/tmp/#{@file_name}"
		@temp_file = "#{@temp_dir}/multipage.tif"
		@file_dir = File.dirname(@path)
	end
	def pdf_cmd
 		if @ext == '.pdf'
			cmd = "gs -r200 -dNOPAUSE -q -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=tiffgray -sCompression=lzw -dBATCH -sOutputFile='#{@temp_file}' -- '#{path}' >> /dev/null 2>> /dev/null"
		elsif @ext == '.djvu'
			cmd = "ddjvu -format=tiff -mode=black -quality=150 '#{@path}' '#{@temp_file}'"
		else
			puts "File type #{@ext} is not supported"
			exit
		end
		return cmd
	end	
	def start_ocr
		FileUtils.mkdir(@temp_dir) unless Dir.exists?(@temp_dir)
		puts "Please wait…"
		system(pdf_cmd)
		ts_cmd = "tesseract '#{@temp_file}' '#{@file_dir}/#{@file_name}' -l #{@lang}"
		system(ts_cmd)
		puts "OCR is done!"
  	FileUtils.rm_rf(@temp_dir)
	end

end

book = Book.new(path, lang)
book.start_ocr
