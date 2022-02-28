module SamplePlugin
  class DeeplinkPageGenerator < Jekyll::Generator
    safe true
    def generate(site)
      collection_labels = site.collections.keys # Get label of every collection
    
      collection_labels.each do |collection_label| # Loop through the collection labels
        all_pages = site.collections[collection_label].docs # Get all pages of this collection by label
        
        all_pages.each do |page|
          filename = page.basename # Get the file name of the .md file
          url = File.basename(filename, File.extname(filename)) # Discards the .md ending
          title = page.data['title'] # Extracts title of the gallery
          folder = page.data['folder'] # Extracts folder
          page_type = page.data['type'] # Extracts type
          collection = collection_label # Saves the collection name
          tiles = page.data['tiles'] # Extracts tiles as an array
          
          unless tiles.nil? # Some pages have no tiles and returns Nil... We'll ignore those
            tiles.each do |tile| # Let's loop through each individual tile on this page and extract path, width and height...
        
              tile_path = tile['path']
              tile_width = tile['width']
              tile_height = tile['height']
            
              unless tile_path.nil? # Some tiles have no path (such as caption tiles) will return Nil. We'll ignore those
                site.pages << DeeplinkPage.new(site, site.source, url, folder, title, collection, tile_path, tile_width, tile_height, page_type)
              end
          end
          
          end
        end
      end
    end
  end

  # Subclass of `Jekyll::Page` with custom method definitions.
  class DeeplinkPage < Jekyll::Page
    def initialize(site, base, url, folder, title, collection, tile_path, tile_width, tile_height, page_type)
      @site = site
      @base = base
      @dir  = "deeplinks" + "/" + collection + "/" + url
      @name = tile_path + '.html'
    
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'deeplink.html')
      
      # Passing data to the template 'deeplink.html'
      self.data['gallery'] = url
      self.data['title'] = "Deeplink from the gallery &ldquo;" + title + "&rdquo;"
      self.data['gallery_title'] = title
      self.data['folder'] = folder
      self.data['collection'] = collection
      self.data['path'] = tile_path
      self.data['width'] = tile_width
      self.data['height'] = tile_height
      unless page_type.nil?
        self.data['type'] = page_type
      end
    end
  end
end