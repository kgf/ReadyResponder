class ItemsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @items = Item.all
    @page_title = "All Items"
  end

  def show
    @item = Item.find(params[:id])
    @last_editor = last_editor(@item)
    @page_title = "Item: #{@item.name}"

    @inspections = @item.inspections
    @repairs = @item.repairs
  end

  def new
    @item = Item.new(status: 'Available')
    @page_title = "New Item"
  end

  def edit
    @item = Item.find(params[:id])
    @page_title = "Editting Item #{@item.name}"
  end

  def create
    @item = Item.new(params[:item])
    if @item.save
      redirect_to @item, notice: 'Item was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      redirect_to @item, notice: 'Item was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    format.html { redirect_to items_url }
  end
end
