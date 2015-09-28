module ItemsHelper
  def render_category(only, exclude, type)
    if only
      str = "（僅#{only}）"
    elsif exclude
      str = "（排除#{exclude}）"
    else
      str = "（全部）"
    end

    str = "#{str}（#{type}）" if type
    str
  end

  def render_stocks_count_by_category(item, only, exclude, type)
    stocks = item.stocks
    if only
      stocks = stocks.where('stocks.category = ?', only)
    elsif exclude
      stocks = stocks.where('stocks.category != ?', exclude)
    end

    if type == 'ifrs'
      stocks = stocks.joins(:statements).where('statements.year >= 2013')
    elsif type == 'gaap'
      stocks = stocks.joins(:statements).where('statements.year < 2013')
    end

    stocks.uniq.count
  end

  def render_statements_count_by_category(item, only, exclude, type)
    statements = item.statements
    if only
      statements = statements.joins(:stock).where("stocks.category = ?", only)
    elsif exclude
      statements = statements.joins(:stock).where("stocks.category != ?", exclude)
    end

    if type == 'ifrs'
      statements = statements.where('statements.year >= 2013')
    elsif type == 'gaap'
      statements = statements.where('statements.year < 2013')
    end

    statements.uniq.count
  end

  def render_children_count_by_category(item, only, exclude, type)
    children = item.children
    if only
      children = children.joins(:item_mappings).where("item_mappings.category = ?", only).uniq
    elsif exclude
      children = children.joins(:item_mappings).where("item_mappings.category != ?", exclude).uniq
    end

    if type == 'ifrs'
      children = children.joins(:item_mappings).where('item_mappings.accounting_standard = ?', ItemMapping.accounting_standards['ifrs']).uniq
    elsif type == 'gaap'
      children = children.joins(:item_mappings).where('item_mappings.accounting_standard = ?', ItemMapping.accounting_standards['gaap']).uniq
    end

    children.count
  end

  def render_descendants_count_by_category(item, only, exclude, type)
    descendants = item.descendants
    if only
      descendants = descendants.joins(:item_mappings).where("item_mappings.category = ?", only).uniq
    elsif exclude
      descendants = descendants.joins(:item_mappings).where("item_mappings.category != ?", exclude).uniq
    end

    if type == 'ifrs'
      descendants = descendants.joins(:item_mappings).where('item_mappings.accounting_standard = ?', ItemMapping.accounting_standards['ifrs']).uniq
    elsif type == 'gaap'
      descendants = descendants.joins(:item_mappings).where('item_mappings.accounting_standard = ?', ItemMapping.accounting_standards['gaap']).uniq
    end

    descendants.count
  end
end
