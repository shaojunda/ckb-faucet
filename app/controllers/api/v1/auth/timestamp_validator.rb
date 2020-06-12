# frozen_string_literal: true

module Api
  module V1
    module Auth
      class TimestampValidator
        TOLERANT_TIME = 5.minutes

        attr_reader :timestamp

        def initialize(timestamp)
          @timestamp = timestamp
        end

        def valid?
          (Time.now.utc.to_i - timestamp.in_time_zone("UTC").to_i).abs <= TOLERANT_TIME
        end

        def validate!
          raise Api::V1::ApiError::TimestampInvalidError unless valid?
        end
      end
    end
  end
end
