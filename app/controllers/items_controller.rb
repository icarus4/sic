class ItemsController < ApplicationController
  def index
    @items = Item.where(parent_id: nil).order(:id)
  end

  def show
    @item = Item.find params[:id]
    item_children_ids = @item.children.pluck(:id)
    item_mappings = ItemMapping.where(item_id: item_children_ids)
    @item_mappings = {}
    item_mappings.each do |item_mapping|
      @item_mappings[item_mapping.item_id.to_s] ||= { stock_ids: [], statement_ids: [] }
      @item_mappings[item_mapping.item_id.to_s][:stock_ids] << item_mapping.stock_id
      @item_mappings[item_mapping.item_id.to_s][:statement_ids] << item_mapping.statement_id
    end

    @item_mappings.each do |k, v|
      @item_mappings[k][:stocks_count] = @item_mappings[k][:stock_ids].uniq.size
      @item_mappings[k][:statements_count] = @item_mappings[k][:statement_ids].uniq.size
    end

    @stocks = @item.stocks.order(:category).uniq
  end
end
