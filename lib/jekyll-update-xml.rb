require "rainbow"
require "builder"
require "rexml/document"
require "open-uri"
require "commonmarker"

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
                        xml.atom :link, :href => "https://docs.coveo.com/en/feed.rss", :rel => "self", :type => "application/rss+xml"
                        xml.title "What's New in Coveo Product Documentation"
                        xml.description "The official RSS feed for Coveo documentation."
                        xml.link "http://docs.coveo.com/en/3082/"
                        new_update_docs.each do |doc|
                            xml.item do
                                xml.title doc.data["title"]
                                xml.description writeDescription(doc)#doc.content
                                xml.pubDate DateTime.now.strftime('%a, %d %b %Y %H:%M:%S %z')
                            end
                        end
                    end
                end
            end

            # Write the update(s) to the X  ML feed
            open(source_path, 'w') do |line|
                line.puts @output
            end
            puts Rainbow("Done.").green
        end

        def writeDescription(doc)
            @description = String.new
            @description << doc.content
            @description << "\n\n"
            @description << "[More](https://docs.coveo.com/en/3082/#" + doc.basename.to_s.gsub(/\.md/, '') + ')'
            @description = CommonMarker.render_html(@description, :DEFAULT)

            @description
        end
    end
end