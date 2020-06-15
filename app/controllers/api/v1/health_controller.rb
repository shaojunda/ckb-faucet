# frozen_string_literal: true

class Api::V1::HealthController < ApplicationController
  skip_before_action :check_header_info, :authenticate!

  def index
    health = Health.new

    render json: HealthSerializer.new(health)
  end
end
