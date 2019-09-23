require "rainbow"
require "builder"
require "rexml/document"

module Jekyll

    # Finds duplicate slugs, logs those in a file, and outputs a warning
    # message in the console.
    class JekyllUpdateXmlFeed < Jekyll::Generator
        safe true
        priority :lowest

        MINIFY_REGEX = %r!(?<=>\n|})\s+!.freeze

        def generate(site)
            puts Rainbow("WE MADE IT!!!!! OIEAJFOAJFOIAJFOAIFJEAOJFEAOIJFEAOJFEIOAJ").red
            generateXml(site.collections["whats-new"])
            @site = site
            @site.pages << persistentFeed unless file_exists?("persistentFeed.txt")
            @site.pages << feed unless file_exists?("feed.xml")
        end

        def source_path(file = "feed.xml")
            File.expand_path "../#{file}", __dir__
        end

        def feed
            xml_feed =  PageWithoutAFile.new(@site, __dir__, "", "feed.txt")
            xml_feed.content = File.read(source_path).gsub(MINIFY_REGEX, "")
            xml_feed.data["layout"] = nil
            xml_feed
        end

        def persistentFeed
            persistent_feed =  PageWithoutAFile.new(@site, __dir__, "", "persistentFeed.txt")
            persistent_feed.content = File.read(source_path("persistentFeed.txt")).gsub(MINIFY_REGEX, "")
            persistent_feed.data["layout"] = nil
            persistent_feed
        end

        def pages_and_files
            @pages_and_files ||= @site.pages + @site.static_files
        end

        # Checks if a file already exists in the site source
        def file_exists?(file_path)
            pages_and_files.any? { |p| p.url == "/#{file_path}" }
        end


        def generateXml(whats_new_collection)
            new_update_docs = Array.new

            @output = ""
            xml = Builder::XmlMarkup.new(:target => @output, :indent => 1)

            # Iteratte  through collection for docs
            whats_new_collection.docs.each do |doc|
                if !File.open(source_path('persistentFeed.txt')).each_line.any?{|line| line.include?(doc.basename)}
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
                open(source_path('persistentFeed.txt'), 'w') do |line|
                    whats_new_collection.docs.each { |doc| line.puts(doc.basename)  }
                end
            end
        end
    end
end