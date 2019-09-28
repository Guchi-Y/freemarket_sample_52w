class ProductsController < ApplicationController
  before_action :move_to_login , except: :show

  def show
    @product = Product.find(params[:id])
    @images = @product.images
  end

  def new
    @category_parents = Category.where(ancestry: nil)
    @product = Product.new
    @image = Image.new
    @brand = Brand.new
  end

  def create
    Product.transaction do
      product = Product.new(product_params)
      product.save!
      params[:images][:image].each do |image|
        product.images.create!(name: image, product_id: product.id)
      end
      Brand.transaction do
        if (brand_name = params[:product][:brand][:name]).present?
          # 既に保存されているブランドは追加で登録しない。
          unless (brand=Brand.find_by(name: brand_name)).present?
            brand = Brand.create!(name: brand_name)
          end
          product.update!(brand_id: brand.id)
        end
      end
    end
      redirect_to new_product_path, notice: '出品が成功しました'
    rescue
      redirect_to new_product_path, alert: '出品が失敗しました'
  end

  def edit
    # 出品者以外が商品情報を編集しようとするとトップにリダイレクトする
    if @product = current_user.seller_products.find_by(id: params[:id])
      @images = @product.images
      @category_parents = Category.where(ancestry: nil)
      @category_children = Category.where(ancestry: @product.parent_id)
      @category_grandchildren = Category.where(ancestry: "#{@product.parent_id}"+"/"+"#{@product.child_id}")
      @sizes = Size.find(@product.size_id).siblings if @product.size_id.present?
      @brand = @product.brand.present? ? @product.brand : Brand.new
      @delivery_methods = DeliveryMethod.where(payside_id: @product.paying_side_id)
    else
      redirect_to tops_path 
    end
  end

  def update
    product = current_user.seller_products.find_by(id: params[:id])
    images = product.images
    # トランザクションを設定して、保存に失敗したらロールバックする
    Product.transaction do
      # productsテーブルをアップデート
      product.update!(product_params) 
      # 保存済みの画像のうちプレビューで削除されたものをDBからも削除
      params[:images][:saved_images].each_with_index do |enum, index|
        images[index].destroy! if enum == "0" 
      end
      # 追加された画像を登録
      if params[:images][:image].present? && params[:images][:image] != [""]
        params[:images][:image].each do |image| 
          product.images.create!(name: image, product_id: product.id)
        end
      end
      # ブランド情報のアップデート
      Brand.transaction do  
        if (brand_name = params[:product][:brand][:name]).present?
          unless (brand=Brand.find_by(name: brand_name)).present?
            brand = Brand.create!(name: brand_name)
          end
          product.update!(brand_id: brand.id)
        else
          product.update!(brand_id: "")
        end
      end
    end
      redirect_to edit_product_path(product), notice: '変更に成功しました'
    rescue
      redirect_to edit_product_path(product), alert: '変更に失敗しました'
  end

   # 親カテゴリーが選択された後に動くアクションAjax
  def get_category_children
    @category_children = Category.find(params[:parent_id]).children
  end

  # 子カテゴリーが選択された後に動くアクションAjax
  def get_category_grandchildren
    @category_grandchildren = Category.find(params[:child_id]).children
  end

  # 孫カテゴリーが選択された後に動くアクションAjax
  def get_size
    selected_category = Category.find(params[:category_id])
    if size_parent = selected_category.sizes[0]
      @sizes = size_parent.children
    elsif size_parent = selected_category.parent.sizes[0]
      @sizes = size_parent.children
    end
  end

  # 配送料の負担を選択された後に動くajax
  def get_delivery_method
    @delivery_methods = DeliveryMethod.where(payside_id: params[:paySide_id].to_i)
  end

  def dropzone
    @product = Product.new
  end

  private

  def product_params
    params.require(:product).permit(
      :name, 
      :description, 
      :category_id, 
      :size_id, 
      :state_id, 
      :paying_side_id, 
      :prefecture_id, 
      :delivery_day_id, 
      :price,
      :parent_id,
      :child_id,
      :delivery_method_id,
      images_attributes: [:image],
      brand_attributes: [:brand]
      ).merge(seller_id: current_user.id)
  end
end

