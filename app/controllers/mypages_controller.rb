class MypagesController < ApplicationController
  def show
    @user = User.find(current_user.id)
    @products = Product.where('seller_id LIKE(?)', current_user.id)
  end

  def profile
  end

  def logout
  end

  def personal_info
  end
end
