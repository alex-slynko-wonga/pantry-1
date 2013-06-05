class Package < ActiveRecord::Base
  attr_accessible :name, :url, :version
end
