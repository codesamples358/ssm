module Ssm
  class Activity < ActiveRecord::Base
    unloadable
    include Model

    # employment_id & project_id columns are for rails association!
    self.column_mapping = { 
      'employmentId' => 'employment_ssm_id', 
      'projectId'    => 'project_ssm_id' 
    }

    self.ssm_attributes = %w(from to note offline mobile employmentId projectId)
    self.record_key = [:employment_ssm_id, :from, :to]

    belongs_to :employment, class_name: "Ssm::Employment"
    belongs_to :issue
    belongs_to :time_entry
    belongs_to :user

    def self.record_attributes(attrs)
      employment = Employment.where(ssm_id: attrs['employment_ssm_id']).first
      project    = Ssm::Project.where(ssm_id: attrs['project_ssm_id']).first

      result = attrs.merge(
        'employment_id' =>  employment.try(:id),
        'project_id'    =>  project.try(:id),
        'from'          =>  Time.at(attrs['from']),
        'to'            =>  Time.at(attrs['to'])
      )

      result
    end

    def find_user
      User.find_by_mail( employment.email )
    end

    def issue_id_from_note
      first_part = self.note.split(/\s+/).first
      first_part.to_i if first_part && first_part.to_i > 0
    end

    def comments_from_note
      if iid = issue_id_from_note
        str = iid.to_s
        idx = self.note.index(str) + str.size
        self.note.from(idx).strip
      else
        self.note
      end
    end

    def find_issue
      if iid = issue_id_from_note
        Issue.find_by_id iid
      end
    end

    def time_entry_scope
      issue.time_entries.where(
        user_id:    user.id,
        spent_on:   from.in_time_zone("EET").to_date, 
        project_id: issue.project_id
      )
    end

    def find_or_create_time_entry
      if issue && user
        time_entry_scope.first || time_entry_scope.new.tap do |new_entry|
          new_entry.activity_id = TimeEntryActivity.default.id
          new_entry.project_id  = issue.project_id
          new_entry.user_id     = user.try(:id)
          new_entry.hours       = self.hours
          new_entry.comments    = comments_from_note
        end
      end
    end

    def self.after_record_update(record)
      record.assign_associations
    end

    def assign_associations
      self.user       = find_user
      self.issue      = find_issue
      self.time_entry = find_or_create_time_entry
      
      self.save!
    end

    def seconds
      to - from
    end

    def hours
      seconds / 3600.0
    end
  end
end