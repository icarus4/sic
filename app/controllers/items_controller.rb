class ItemsController < ApplicationController
  def index
    @items = Item.where(parent_id: nil).order(:id)
  end

  def show
    @item = Item.find params[:id]

    if params[:category] == 'finance'
      @stocks = @item.stocks.where(category: '金融保險業').order(:category).uniq
      @children_items = @item.children.joins(:stocks).where("stocks.category = '金融保險業'").uniq
    elsif params[:category] == 'exclude-finance'
      @stocks = @item.stocks.where("category != '金融保險業'").order(:category).uniq
      @children_items = @item.children.joins(:stocks).where("stocks.category != '金融保險業'").uniq
    else
      @stocks = @item.stocks.order(:category).uniq
      @children_items = @item.children
    end
  end
end
