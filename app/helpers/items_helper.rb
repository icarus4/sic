module ItemsHelper
  def render_category(only, exclude)
    if only
      "（僅#{only}）"
    elsif exclude
      "（排除#{exclude}）"
    else
      "（全部）"
    end
  end

  def render_stocks_count_by_category(item, only, exclude)
    stocks = item.stocks
    if only
      stocks = stocks.where(category: only)
    elsif exclude
      stocks = stocks.where('category != ?', exclude)
    end

    stocks.uniq.count
  end

  def render_statements_count_by_category(item, only, exclude)
    statements = item.statements
    if only
      statements = statements.joins(:stock).where("stocks.category = ?", only)
    elsif exclude
      statements = statements.joins(:stock).where("stocks.category != ?", exclude)
    end
    statements.uniq.count
  end

  def render_children_count_by_category(item, only, exclude)
    children = item.children
    if only
      children = children.joins(:stocks).where("stocks.category = ?", only).uniq
    elsif exclude
      children = children.joins(:stocks).where("stocks.category != ?", exclude).uniq
    end

    children.count
  end

  def render_descendants_count_by_category(item, only, exclude)
    descendants = item.descendants
    if only
      descendants = descendants.joins(:stocks).where("stocks.category = ?", only).uniq
    elsif exclude
      descendants = descendants.joins(:stocks).where("stocks.category != ?", exclude).uniq
    end

    descendants.count
  end
end
