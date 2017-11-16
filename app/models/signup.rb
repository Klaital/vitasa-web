class Signup < ApplicationRecord
    belongs_to :user
    belongs_to :shift

    after_initialize :init

    def init
      self.approved = false if self.approved.nil?
      self.hours ||= 0
    end
end
