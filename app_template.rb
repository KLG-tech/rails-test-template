gem_group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

gem_group :development do
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
end

gem_group :test do
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'webmock', require: 'webmock/rspec'
  gem 'timecop'
  gem 'simplecov', require: false
end

gem_group :development, :test do
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rake", require: false
  gem "standard", require: false
end

template = URI("https://gist.githubusercontent.com/rafeequl/12c0678e05853998bac361c6730a7d3a/raw/ca38d2a86d9943b5b45ba883625ff2c58ade4a93/rubocop.yml")
create_file ".rubocop.yml", template.read

if yes?("Would you like to add ruby-lsp-rails?")
  gem_group :development do
    gem "ruby-lsp-rails"
  end
end

run "touch '.rubocop_todo.yml'"

run 'bundle install'

rails_command 'generate rspec:install'

File.open(Rails.root.join('spec/rails_helper.rb'), 'r+') do |file|
  lines = file.each_line.to_a
  config_index = lines.find_index("RSpec.configure do |config|\n")
  lines.insert(config_index, "\nDir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }\n\n")
  file.rewind
  file.write(lines.join)
end

# Add SimpleCov to spec_helper.rb
files = [
  'spec/spec_helper.rb'
]
files.each do |filename|
  next unless File.exist?(filename)

  prepend_to_file filename, <<~TEMPLATE
    require 'simplecov'
    SimpleCov.start 'rails' do
      add_filter 'app/channels'
      add_filter 'app/views'
      add_filter 'app/helpers'
      add_filter 'app/policies'
      add_filter 'app/mailers'
      add_filter 'app/prawns'
      add_group 'Services', 'app/services'
    end

  TEMPLATE
end

append_to_file '.gitignore', <<~TEMPLATE
  # Ignore coverage
  /coverage
TEMPLATE

# END of SimpleCov

factory_bot_rb = %(require 'factory_bot_rails'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.use_parent_strategy = true
)

shoulda_rb = %(require 'shoulda/matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
)

time_helper_rb = %(RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
)

run 'mkdir spec/support'

File.open(Rails.root.join('spec/support/time_helper.rb'), 'w') do |file|
  file.write(time_helper_rb)
end

File.open(Rails.root.join('spec/support/factory_bot.rb'), 'w') do |file|
  file.write(factory_bot_rb)
end

File.open(Rails.root.join('spec/support/shoulda.rb'), 'w') do |file|
  file.write(shoulda_rb)
end

File.open(Rails.root.join('spec/support/vcr.rb'), 'w') do |file|
  vcr = URI("https://gist.githubusercontent.com/rafeequl/2d599cbc6afe3e4108070faf7f335d89/raw/3634a7702401a356ac9bf2e90d1f02cda39193a5/vcr.rb").read
  file.write(vcr)
end

dot_rspec = %(--require rails_helper
--color
--format documentation
--tag ~slow
)

File.open(Rails.root.join('.rspec'), 'w') do |file|
  file.write(dot_rspec)
end

run 'bundle exec guard init'
run 'bundle binstub guard'
run 'bundle binstub rspec'

run 'rm -rf test' if yes?('Do you want to remove the /test directory?')

if yes?('Would you like to generate factories for your existing models?')
  Dir.glob(Rails.root.join('app/models/*.rb')).each { |file| require file }
  models = ApplicationRecord.send(:subclasses).map(&:name)

  models.each do |model|
    run("rails generate factory_bot:model #{model} #{model.constantize.columns.map do |column|
                                                       "#{column.name}:#{column.type}"
                                                     end.join(' ')}")
  end
end
