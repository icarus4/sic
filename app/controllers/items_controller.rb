class ItemsController < ApplicationController
  def index
    @items = Item.where(parent_id: nil).order(:id)
  end

  def show
    @item = Item.find params[:id]
    @stocks = @item.stocks.order(:category).uniq
  end
end
