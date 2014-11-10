# Using the skypager gem to build dynamic, data driven sites with middleman

Skypager takes an already powerful website creation tool 'Middleman' and adds a few key integrations
with services like Dropbox and Google Drive / Google Documents, as well as Amazon S3, Cloudfront, and DNSimple.

This automates a ton of boring setup chores and allows designers and developers to crank out dynamic, data driven websites
without having to worry too much about servers.  And since these websites are all technically 'static', and backed by a global CDN, 
Skypager websites will be fast as hell. 

The skypager gem is open source.  If you want to automate your builds and releases every time files change on Dropbox or any time data changes in a Google Spreadsheet, you
can either run the skypager build server on your own server or you can sign up on skypager.io and we will set all of that up for you as well.

## Using the skypager gem in your own projecs

In this tutorial, we are going to use the skypager gem and the skypager middleman extension to build a photo gallery website.

The information about our photo galleries is going to be stored in a google spreadsheet.  The photo galleries themselves, are going to be stored on Dropbox.

- 1) create a new middleman project

  ```bash
  middleman init
  ```

- 2) add the skypager gem, and activate it in your config.rb

  ```ruby
  # Gemfile

  gem 'skypager', github: "architects/skypager", branch: "master"

  # config.rb

  activate :skypager
  ```

- 3) setup the google drive and dropbox integrations.  this requires you
  to create applications in the respective developer consoles for google
  and dropbox

  ```bash
  alias be='bundle exec'
  be skypager setup
  ```

- 4) once your applications are setup, you can create a google
  spreadsheet datasource.  the spreadsheet data source will be used to
  generate dynamic pages and content to be displayed with our html
  templates

  ```bash
  be skypager create datasource galleries
  ```

  follow the prompts, selecting 'google spreadsheet' and enter in
  some fields for this data source.

  for this example we will use:

  `title description cover_image status release_date`

  this will end up creating the following line in our `config.rb`

  ```ruby
  # config.rb

  data_source :galleries, :type => "google", :key => "..."
  ```

- 5) in order to get pretty urls from our data source, we are going to 
    configure the data source to make 'slugs' out of the title column.

    edit the config.rb file:

  ```ruby
  # config.rb

  data_source :galleries, :type => "google", :key => "...", :slug_column => 'title'
  ```

- 6) with this done, we will now have access to the galleries data
  source from within any template, or from within the `config.rb` file
  itself which means we can use the data source to generate dynamic
  urls such as: `/galleries/my-gallery-title` which will display the
  info in the spreasheet.

- 7) let's open up the actual spreadsheet and add some rows to it.

  ```bash
  be skypager edit datasource galleries
  ```

  this will open up the spreadsheet in your browser for you.

- 8) with some actual data in our spreadsheet, lets get a couple of
  pages rendered with it. open up the `source/index.html.erb` file and
  put in the following content.

  ```erb
  <h1>Galleries</h1>

  <ul>
    <% data.galleries.each do |gallery| %>
      <li>
        <p><%= gallery.title %></p>
      </li>
    <% end %>
  </ul>
  ```

  here we are accessing the data from the galleries spreadsheet in our template
  by iterating over `data.galleries` and listing each one.  If we edit the spreadsheet,
  and add a new row, and then refresh the page, you will see the new data show up. 

  **note:** if you don't see data showing up, you can restart your development server. in development,
  skypager attempts to keep up to date, but in order not to keep nagging the server we do 
  some checking and sometimes this might make data stale.  

- 9) we can create separate pages for each row in the spreadsheet. 

  ```ruby
  # config.rb
  map_data_source(:galleries, :url => "/galleries/:slug", :to => "gallery.html.erb", :as => :gallery)
  ```

  this will dynamically add routes for every row in the galleries data source, and display that individual
  row using the `gallery.html.erb` template

  since we added the `slug_column` option and set it to title, then it will turn our title column data
  into a friendly url.  for example: `My Awesome Gallery` becomes available at `/galleries/my-awesome-gallery`
  
  editing the `source/gallery.html.erb` template file:
 
  ```erb
  <h1><%= gallery.title %></h1>
  <%= image_tag(gallery.cover_image) %>
  <p><%= gallery.description %></p> 
  ``` 

  and now editing the `source/index.html.erb` template file we can link to our galleries.

  ```erb
  <a href="/galleries/<%= gallery.slug %>">
    <%= gallery.title %>
  </a>
  ```

### Using dropbox as a media store for your website content

- 10) a gallery isn't much without some images. in this tutorial, we are going to integrate with Dropbox to store our 
      image files. 
