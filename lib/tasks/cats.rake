namespace :cats do

  desc "Collate cat information"
  task :get_cats_info do
    require 'capybara'
    require 'capybara/poltergeist'
    require 'capybara/dsl'
    require 'csv'

    include Capybara::DSL

    # Configure Capybara to use Poltergeist as the driver
    Capybara.default_driver = :poltergeist

    # Configure Poltergeist to not blow up on websites with js errors aka every website with js

    # See more options at https://github.com/teampoltergeist/poltergeist#customization
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end

    # Visit Wikipedia - Cats
    url = "https://en.wikipedia.org/wiki/List_of_cat_breeds"
    visit url

    # Grab list of cats
    cats = all(".wikitable td:first-child a:first-child")
    cats_with_info = []

    cats.each do |cat|
      cat_info = {}

      cat_info[:name] = if cat["class"] == "new"
        cat["title"].gsub(" (page does not exist)", "")
      else
        cat["title"]
      end

      cat_info[:url] = cat["href"]

      cats_with_info << cat_info
    end

    cats_with_info.each do |cat|
      visit cat[:url]

      if status_code == 404
        cat[:snippet] = ""
      else
        cat[:snippet] = all("p")[0].text
      end
    end

    cats_with_info.each do |cat|
      Cat.create(name: cat[:name], description: cat[:snippet])
    end

    # CSV.open("./lib/assets/cats.csv", "w") do |csv|
    #   csv << ["Breed", "About"]
    #   cats_with_info.each do |cat|
    #     csv << [cat[:name], cat[:snippet]]
    #   end
    # end
  end
end
