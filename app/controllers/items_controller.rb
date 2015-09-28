class ItemsController < ApplicationController

  def index
    @items = Item.where(parent_id: nil).order(:id)
  end

  def show
    @item = Item.find params[:id]

    @stocks = @item.stocks
    @children_items = @item.children

    if params[:only]
      @stocks = @stocks.where('stocks.category = ?', params[:only])
      @children_items = @children_items.joins(:item_mappings).where("item_mappings.category = ?", params[:only])
    elsif params[:exclude]
      @stocks = @item.stocks.where("stocks.category != ?", params[:exclude])
      @children_items = @children_items.joins(:item_mappings).where("item_mappings.category != ?", params[:exclude])
    end

    if params[:type] == 'gaap'
      @stocks = @stocks.joins(:statements).where("statements.year < 2013")
      @children_items = @children_items.joins(:item_mappings).where("item_mappings.accounting_standard = ?", ItemMapping.accounting_standards['gaap'])
    elsif params[:type] == 'ifrs'
      @stocks = @stocks.joins(:statements).where("statements.year >= 2013")
      @children_items = @children_items.joins(:item_mappings).where("item_mappings.accounting_standard = ?", ItemMapping.accounting_standards['ifrs'])
    end

    @stocks = @stocks.order(:category).uniq
    @children_items = @children_items.uniq
  end
end
