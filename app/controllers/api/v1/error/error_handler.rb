
module Api
  module V1
    module Error
      module ErrorHandler
        def handle_errors(claim_event)
          errors = claim_event.errors
          raise Api::V1::ApiError::Pk160InvalidError if errors.include?(:pk160)
          raise Api::V1::ApiError::RequestUUIDInvalidError if errors.include?(:request_uuid)

          handle_quota_config_errors(errors)
        end

        def handle_quota_config_errors(errors)
          quota_config_prefix = "Quota config"
          errors.full_messages_for(:quota_config).each do |message|
            case message.delete_prefix(quota_config_prefix).strip
            when "h24_quota"
              raise Api::V1::ApiError::ExceedsDailyQuotaLimitPerProductError
            when "h24_quota_per_request_type"
              raise Api::V1::ApiError::ExceedsDailyQuotaLimitPerTypeError
            when "h24_total_quota"
              raise Api::V1::ApiError::ExceedsDailyQuotaLimitError
            end
          end
        end
      end
    end
  end
end

