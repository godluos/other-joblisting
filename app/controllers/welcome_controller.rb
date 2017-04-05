class WelcomeController < ApplicationController
  def index
    flash[:warning] = "1"
  end
end
