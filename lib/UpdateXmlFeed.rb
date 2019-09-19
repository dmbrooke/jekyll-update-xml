module Jekyll

    # Finds duplicate slugs, logs those in a file, and outputs a warning
    # message in the console.
    Jekyll::Hooks.register :site, :pre_render do |site|

        require "rainbow"
        require "builder"
        require "rexml/document"

        whats_new_collection = site.collections["whats-new"]

        new_update_docs = Array.new

        @output = ""
        xml = Builder::XmlMarkup.new(:target => @output, :indent => 1)

        # Iteratte  through collection for docs
        whats_new_collection.docs.each do |doc|
            if !File.open('./assets/persistentFeed.xml').each_line.any?{|line| line.include?(doc.basename)}
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
            open('./assets/feed.xml', 'w') do |line|
                line.puts @output
            end

            # Update the persisted files
            open('./assets/persistentFeed.xml', 'w') do |line|
                whats_new_collection.docs.each { |doc| line.puts(doc.basename)  }
            end
        end
    end
end