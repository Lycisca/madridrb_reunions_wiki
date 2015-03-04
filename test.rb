URL_BASE = "https://github.com"
MONTHS =  [nil] + %w(Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre)

#Check || install nokogiri
begin
  gem 'nokogiri'
rescue LoadError
  system("gem install nokogiri")
  Gem.clear_paths
end

require 'nokogiri'
require 'open-uri'
require 'json'

def build_json(data, tittle, link)
  date 	= data.xpath("//td").first.text
	fecha	=  Date.strptime(date, "%Y-%m-%d")
	
	h = {"#{MONTHS[fecha.month]}_#{fecha.year}" => 
				{	
					link: 	link,
					date: 	fecha,
					month: 	MONTHS[fecha.month], 
					year: 	fecha.year,
					topics: "" #TODO
				}
	    }.to_json
	puts h
end

home = Nokogiri::HTML(open("https://github.com/madridrb/madridrb.github.io/wiki"))
links = Hash.new
home.css(".wiki-pages//a").each { |list| links["#{list.text.gsub(' ', '_')}.md"] = list['href'] }

#Save files
links.each do |tittle, link|
	unless tittle == "Home.md"
		unless File.exists?("./#{tittle}")
			reunion = Nokogiri::HTML(open("#{URL_BASE}#{link}"))
			File.write("./#{tittle}", reunion.css(".markdown-body"))
		end

	#Parsing files
		file = File.open(tittle)
		reunion_content = Nokogiri::XML(file)
		build_json(reunion_content, tittle, link)
		file.close
	end
end