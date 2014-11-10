require 'skypager/extension'

activate :skypager
activate :directory_indexes

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :directory_indexes
end

data_source :galleries, :type => 'google',
                        :key  => '1mTLlaMSE-scs_MplJ2GLPJ9n0q9Xx1CMlWJL-70PW6Q',
                        :slug_column => 'title'

map_data_source(:galleries, :url => "/galleries/:slug", :to => "gallery.html", :as => :gallery)

dropbox_sync("source/images/galleries")

helpers do
  def galleries
    Pathname(source_dir).join("images","galleries")
  end

  def gallery_images_for(gallery_folder)
    folder = galleries.join(gallery_folder)

    folder.children
      .select(&:file?)
      .reject {|f| f.to_s.match(/^\./) }
      .map {|f| f.relative_path_from(galleries) }
  end
end
