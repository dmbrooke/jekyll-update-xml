require "rainbow"
require "builder"
require "rexml/document"
require "open-uri"

module Jekyll

    # Finds duplicate slugs, logs those in a file, and outputs a warning
    # message in the console.
    class JekyllUpdateXmlFeed < Jekyll::Generator
        safe true
        priority :lowest

        def generate(site)
            @site = site
            generateXml(site.collections["whats-new"])
        end

        def source_path(file = "feed.xml")
            File.expand_path "./#{file}", @site.source
        end

        def generateXml(whats_new_collection)
            new_update_docs = Array.new

            @output = ""
            xml = Builder::XmlMarkup.new(:target => @output, :indent => 1)

            begin
                puts Rainbow("Making a connection to staging...").yellow
                source = open("https://docs.coveo.com/en/3082/")
                page_content = source.read

                if page_content.match(/(?<=<meta name="whats-new" content=')(.|\n)*?(?=')/m) != nil
                    puts Rainbow("FOUND MATCH").green
                    test = page_content.match(/(?<=<meta name="whats-new" content=')(.|\n)*?(?=')/m).to_s.strip
                    whats_new_collection.docs.each do |doc|
                        if !test.each_line.any?{|line| line.include?(doc.basename)}
                            new_update_docs << doc
                            puts Rainbow("Adding " + doc.data["title"]).blue
                        end
                    end
                else
                    puts Rainbow("DIDNT FIND MATCH").red
                    whats_new_collection.docs.each do |doc|
                        new_update_docs << doc
                    end
                end
            rescue => exception
                puts Rainbow("Page can not be reached.").red
                whats_new_collection.docs.each do |doc|
                    new_update_docs << doc
                end
            end

            if new_update_docs.size > 0
                puts Rainbow("Updating feed.").yellow
                xml.instruct!
                xml.updates do
                    new_update_docs.each do |doc|
                        xml.update do
                            xml.collection doc.data["category"]
                            xml.typeOfChange doc.data["typeOfChange"]
                            xml.date doc.data["createdDate"]
                            xml.content doc.content
                            xml.links do
                                doc.data["links"].each do |link|
                                    xml.link link
                                end
                            end
                        end
                    end
                end

                # Write the update(s) to the XML feed
                open(source_path, 'w') do |line|
                    line.puts @output
                end

                # Update the persisted files
                #open(source_path('persistentFeed.txt'), 'w') do |line|
                #    whats_new_collection.docs.each { |doc| line.puts(doc.basename)  }
                #end
            end
        end
    end
end