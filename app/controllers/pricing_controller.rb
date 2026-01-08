class PricingController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @plans = Plan.active.ordered_by_price
  end
end
