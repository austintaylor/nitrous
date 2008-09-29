class ChickensController < ApplicationController

  def create
    @chicken = Chicken.create(params[:chicken])
    redirect_to chickens_url
  end
end
