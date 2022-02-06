class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include SessionsHelper
  include RequestUrl
end
