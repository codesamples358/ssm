require_relative 'api'

module Ssm
  class Project < ActiveRecord::Base
    unloadable

    include Model
    self.ssm_attributes = %w(id name clientId color endDate)
  end
end