URL_BASE = "https://github.com"
months =  %w(Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre)

require 'nokogiri'
require 'open-uri'
require 'json'

page = Nokogiri::HTML(open("#{URL_BASE}/madridrb/madridrb.github.io/wiki"))
links = page.xpath("//a[@class='wiki-page-link']")

# Save files
puts "Saving files in HTML ..."
links.each do |link|
	unless link.text == 'Home'
		filename_html = "#{link.text.gsub(' ', '_')}.html"
		edit_link = "#{URL_BASE}#{link['href']}"

		unless File.exists?("./#{filename_html}")
			File.write(filename_html, Nokogiri::HTML(open(edit_link)).css('.markdown-body'))
			puts "  #{filename_html}"
		end
	end
end

files = Dir["*.html"]

# Parse files
puts "Convert and saving files in JSON ..."
files.each do |file|
	file_content = File.open(file, "r").read
	doc = Nokogiri::XML(file_content)

	date, time, location = doc.css("table td")
	date 	= Date.strptime(date, "%Y-%m-%d")
	month 	= months[date.month]
	year 	= date.year
	tittle 	= (doc.css('h2')[0].text).strip
	

	speaker_name 	= (doc.css('h2')[1].text).strip unless doc.css('h2')[1].nil?
	speaker_twitter = doc.css('h2')[1].css('a')[1]['href'] unless doc.css('h2')[1].nil?
	speaker 		= [{ name: speaker_name, twitter: speaker_twitter }]


	video_url = doc.css('h3').css('a')[1]['href'] if !doc.css('h3').css('a')[1].nil?


	participants = Array.new
	persons = doc.css('ul').css('.task-list').css('li').css('a')
	persons.each do |speaker|
		participants << { name: speaker.text, twitter: speaker['href'] }
	end


	sponsors = Array.new
	companies = doc.xpath("//img[@data-canonical-src]")
	companies.each do |company|
	sponsors << { 	name: company.xpath("@alt").text, url: company.xpath("../@href").text, img: company.xpath("@data-canonical-src").text }
	end

	description = doc.xpath('//p[not(position()=last())]').text().strip


	hash = { month: month, year: year, date: date, topics: {tittle: tittle, speakers: speaker},
          	 location: location.text.strip, video_url: video_url, participants: participants, sponsors: sponsors, description: description}

    # Write Json
	filename_json = "#{file.gsub('.html', '')}.json"
	File.open(filename_json, "w") do |file|
		file.write(hash.to_json)
	end

	puts "  #{filename_json}"
end