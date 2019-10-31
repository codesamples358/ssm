require_relative 'api'

module Ssm
  module Model
    module ClassMethods
      def db_column(ssm_attribute)
        if column = self.column_mapping[ssm_attribute]
          # custom mapping that specific models may define
          return column
        end

        case ssm_attribute
        when 'id' then 'ssm_id'
        else ssm_attribute.underscore
        end
      end


      # requests entity list from ScreenshotMonitor's api & creates db records for it
      def sync
        api_method = self.name.demodulize.underscore.pluralize
        jsons = api.send(api_method)

        sync_jsons(jsons)
      end

      def sync_jsons(jsons)
        jsons.each do |ssm_json|
          attrs = {}

          self.ssm_attributes.each do |ssm_key|
            db_key = db_column(ssm_key)

            if self.columns.any? {|column| column.name == db_key}
              attrs[ db_key ] = ssm_json[ssm_key]
            end
          end

          key_columns = Array( self.record_key ).map(&:to_s)
          attrs       = record_attributes(attrs)
        
          condition   = attrs.slice(*key_columns)
          record      = self.where(condition).first_or_initialize

          record.update_attributes attrs
          after_record_update(record)
        end
      end

      def api
        @api ||= Api.new
      end

      # may be overriden in subclasses
      def record_attributes(attrs)
        attrs
      end

      # may be overriden in subclasses
      def after_record_update(record)
      end
    end

    def self.included(base)
      base.class_eval do
        class_attribute :ssm_attributes
        class_attribute :record_key
        class_attribute :column_mapping

        self.record_key     = :ssm_id
        self.column_mapping = {}

        delegate :api, to: 'self.class'
      end

      base.extend(ClassMethods)
    end
  end
end