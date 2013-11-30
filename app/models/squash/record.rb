module Squash
  class Record < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "squash_#{::Rails.env}"
  end
end