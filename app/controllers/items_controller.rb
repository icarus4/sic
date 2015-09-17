class ItemsController < ApplicationController

  def index
    @items = Item.where(parent_id: nil).order(:id)
  end

  def show
    @item = Item.find params[:id]

    @stocks = @item.stocks
    @children_items = @item.children

    if params[:only]
      @stocks = @stocks.where(category: params[:only])
      @children_items = @children_items.joins(:stocks).where("stocks.category = ?", params[:only])
    elsif params[:exclude]
      @stocks = @item.stocks.where("category != ?", params[:exclude])
      @children_items = @children_items.joins(:stocks).where("stocks.category != ?", params[:exclude])
    end

    if params[:type] == 'gaap'
      @stocks = @stocks.joins(:statements).where("statements.year < 2013")
      @children_items = @children_items.joins(:statements).where("statements.year < 2013")
    elsif params[:type] == 'ifrs'
      @stocks = @stocks.joins(:statements).where("statements.year >= 2013")
      @children_items = @children_items.joins(:statements).where("statements.year >= 2013")
    end

    @stocks = @stocks.order(:category).uniq
    @children_items = @children_items.uniq
  end
end
