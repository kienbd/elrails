# Load the Rails application.
require File.expand_path('../application', __FILE__)


# Initialize the Rails application.
Elrails::Application.initialize!
require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "http://202.191.58.55/cas"
  #:cas_base_url => "http://123.30.234.253"
)




