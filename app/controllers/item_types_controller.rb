class ItemTypesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  before_action :set_common_values, only: [:show, :edit, :update, :destroy]

  def index
    @item_types = ItemType.all
  end

  def show
    @last_editor = last_editor(@item_type)
  end

  def new
    @item_type = ItemType.new
    @item_type.item_category = ItemCategory.find(params[:item_category_id])
    @item_type.status = "Active"
  end

  def edit
  end

  def create
    @item_type = ItemType.new(item_type_params)
    if @item_type.save
      redirect_to @item_type, notice: 'Item type was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @item_type.update_attributes(item_type_params)
      redirect_to @item_type, notice: 'Item type was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /item_types/1
  # DELETE /item_types/1.json
  def destroy
    @item_type.destroy
  end

  private

  def set_common_values
    @item_category = ItemCategory.find(params[:item_category_id]) if params[:item_category_id]
    @item_type = ItemType.find(params[:id])
  end

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def item_type_params
    params.require(:item_type).permit(:is_a_group, :is_groupable,
                               :name, :parent_id, :status, :item_category_id,
                                    :description, :item_type_image )
  end
end
