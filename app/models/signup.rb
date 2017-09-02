class Signup < ApplicationRecord
    belongs_to :user
    belongs_to :site

    after_initialize :init

    def init
      self.approved = false if self.approved.nil?
      self.hours ||= 0
    end
end