require "rainbow"
require "builder"
require "rexml/document"
require "open-uri"

module Jekyll

    # Generates/updates the RSS feed for docs.coveo.com
    class JekyllUpdateXmlFeed < Jekyll::Generator
        safe true
        priority :lowest

        def generate(site)
            @site = site
            generateXml(site.collections["whats-new"])
        end

        def source_path(file = "feed.rss")
            File.expand_path "./#{file}", @site.source
        end

        def generateXml(whats_new_collection)
            new_update_docs = Array.new

            @output = ""
            xml = Builder::XmlMarkup.new(:target => @output, :indent => 1)

            begin
                source = open("http://docs.coveo.com/en/3082/")
                page_content = source.read

                if page_content.match(/(?<=<meta name="whats-new" content=')(.|\n)*?(?=')/m) != nil
                    test = page_content.match(/(?<=<meta name="whats-new" content=')(.|\n)*?(?=')/m).to_s.strip
                    whats_new_collection.docs.each do |doc|
                        if !test.each_line.any?{|line| line.include?(doc.basename)}
                            new_update_docs << doc
                        end
                    end
                else
                    whats_new_collection.docs.each do |doc|
                        new_update_docs << doc
                    end
                end
            rescue => exception
                whats_new_collection.docs.each do |doc|
                    new_update_docs << doc
                end
            end

            if new_update_docs.size > 0
                puts Rainbow("Updating feed...").yellow

                xml.instruct! :xml, :version => "1.0"
                xml.rss :version => "2.0", "xmlns:atom" => 'http://www.w3.org/2005/Atom' do
                    xml.channel do
                        xml.atom :link, :href => "http://dallas.example.com/rss.xml", :rel => "self", :type => "application/rss+xml"
                        xml.title "Whats New in Coveo Documentation"
                        xml.description "The official RSS feed for Coveo documentation."
                        xml.link "http://docs.coveo.com/en/3082/"
                        new_update_docs.each do |doc|
                            xml.item do
                                xml.title doc.data["title"]
                                xml.description doc.content
                                xml.pubDate DateTime.parse(doc.data["createdDate"].to_s).strftime('%a, %d %b %Y %H:%M:%S %z')
                            end
                        end
                    end
                end
            end

            # Write the update(s) to the XML feed
            open(source_path, 'w') do |line|
                line.puts @output
            end
        end
    end
end