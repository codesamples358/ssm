require_relative 'api'

module Ssm
  class Employment < ActiveRecord::Base
    unloadable
    has_many :activities, class_name: "Ssm::Activity"
    belongs_to :user

    include Model
    self.ssm_attributes = %w(id name email registered lastActive canEdit payRate endDate inPause activityStatus config defaultName role accountInfo projects activity)

    def find_user
      User.find_by_mail email
    end

    def self.after_record_update(record)
      record.assign_associations
    end

    def assign_associations
      self.user       = find_user
      self.save!
    end

    DEFAULT_FROM = Date.new(2019, 1, 1)

    def default_time_range(time_range = {})
      default = { from: DEFAULT_FROM.to_time, to: Time.now }
      default.merge time_range
    end

    # requests activities from ScreenshotMonitor's api & creates db records for activities
    def sync_activities(time_range = {})
      request_params = default_time_range(time_range)
      request_params['employmentId'] = self.ssm_id

      request_params[:from] = request_params[:from].to_i
      request_params[:to]   = request_params[:to].to_i

      jsons = api.activities(request_params)
      # binding.pry
      Activity.sync_jsons jsons
    end

    # update all time_entries for this user
    # using data previously fetched from ScreenshotMonitor & stored into db
    def sync_time_entries(time_range = {})
      time_range = default_time_range time_range
      scope = Ssm::Activity.where(user_id: find_user.id)

      scope = scope.where('ssm_activities.from >= ?', time_range[:from]) if time_range[:from]
      scope = scope.where('ssm_activities.from <= ?', time_range[:to]) if time_range[:to]

      scope.all.group_by(&:time_entry).each do |time_entry, activities|
        total = activities.map(&:seconds).sum / 3600.0
        time_entry.update_attribute(:hours, total) if time_entry
      end
    end
  end
end