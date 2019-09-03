class UsersController < ApplicationController
 
  def index
  end

  def new  
  end

  def customer_info 
    @user = User.new
  end

  def sms_comfi
    session[:nickname] = user_params[:nickname]
    session[:email] = user_params[:email]
    session[:password] = user_params[:password]
    session[:password_confirmation] = user_params[:password_confirmation]
    session[:last_name] = user_params[:last_name]
    session[:first_name] = user_params[:first_name]
    session[:last_name_kana] = user_params[:last_name_kana]
    session[:first_name_kana] = user_params[:first_name_kana]
    session[:birth_year] = user_params[:birth_year]
    session[:birth_month] = user_params[:birth_month]
    session[:birth_day] = user_params[:birth_day]
    @user = User.new 
  end
  def address
    session[:mobile_number] = user_params[:mobile_number]
    @user = User.new
    @user.save
  end
  def create
    @user = User.new(
      nickname: session[:nickname],
      email: session[:email],
      password: session[:password],
      password_confirmation: session[:password_confirmation],
      last_name: session[:last_name], 
      first_name: session[:first_name], 
      last_name_kana: session[:last_name_kana], 
      first_name_kana: session[:first_name_kana],
      birth_year: session[:birth_year], 
      birth_month: session[:birth_month], 
      birth_day: session[:birth_day], 
      mobile_number: session[:mobile_number]
    )
      if @user.save
        session[:id] = @user.id
        redirect_to complete_users_path
      else
        render 'users/new'
    end
    
  end

  def card  
  end

  def complete  
  end

end
private

  def user_params
    params.require(:user).permit(
      :nickname, 
      :email, 
      :password, 
      :password_confirmation, 
      :last_name, 
      :first_name, 
      :last_name_kana, 
      :first_name_kana, 
      :birth_year,
      :birth_month,
      :birth_day,
      :mobile_number,
      :profile,
      :profile
  )
  end