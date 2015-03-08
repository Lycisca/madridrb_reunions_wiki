#!/usr/bin/ruby

require 'open-uri'
require 'nokogiri'
require 'kramdown'
require 'json'

page = Nokogiri::HTML(open("https://github.com/madridrb/madridrb.github.io/wiki"))
links = page.css(".wiki-pages//a")
months = %w(Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre)


links.each do |link|
	unless link.text == 'Home'
		filename_html = "#{link.text.gsub(' ', '_')}.html"
		edit_link = "https://github.com#{link['href']}"

		File.open(filename_html, "w") do |file|
			file.write(Nokogiri::HTML(open(edit_link)).css('.markdown-body'))
		end

		puts "#{filename_html} written to disk."
	end
end

files = Dir["*.html"]


files.each do |file|
	file_content = File.open(file, "r").read
	doc = Nokogiri::XML(file_content)

	date, time, location = doc.css("table td")
	date = Date.strptime(date, "%Y-%m-%d")
	month = months[date.month]
	year = date.year
	tittle = (doc.css('h2')[0].text).strip
	speaker_name = (doc.css('h2')[1].text).strip unless doc.css('h2')[1].nil?
	speaker_twitter = doc.css('h2')[1].css('a')[1]['href'] unless doc.css('h2')[1].nil?
	speaker = {:name => speaker_name, :twitter => speaker_twitter}

	video_url = doc.css('h3').css('a')[1]['href'] if !doc.css('h3').css('a')[1].nil?

	participants = Array.new
	persons = doc.css('ul').css('.task-list').css('li').css('a')
	persons.each do |speaker|
		participants << {:name => speaker.text, :twitter => speaker['href']}
	end

	hash = {:month => month, :year => year, :date => date, :topics => {:tittle => tittle, :speakers => speaker},
					:location => location.text, :video_url => video_url}

	filename_json = "#{file.gsub('.html', '')}.json"
	File.open(filename_json, "w") do |file|
		file.write(hash.to_json)
	end

	puts "#{filename_json} written to disk."
end
