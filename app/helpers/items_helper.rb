module ItemsHelper
  def render_category(category)
    if category == 'finance'
      "（金融股）"
    elsif category == 'exclude-finance'
      "（非金融股）"
    else
      "（金融股 + 非金融股）"
    end
  end

  def render_stocks_count_by_category(item, category)
    if category == 'finance'
      item.stocks.finance.uniq.count
    elsif category == 'exclude-finance'
      item.stocks.exclude_finance.uniq.count
    else
      item.stocks.uniq.count
    end
  end

  def render_statements_count_by_category(item, category)
    if category == 'finance'
      item.statements.joins(:stock).finance.uniq.count
    elsif category == 'exclude-finance'
      item.statements.joins(:stock).exclude_finance.uniq.count
    else
      item.statements.uniq.count
    end
  end

  def render_children_count_by_category(item, category)
    if category == 'finance'
      item.children.joins(:stocks).finance.uniq.count
    elsif category == 'exclude-finance'
      item.children.joins(:stocks).exclude_finance.uniq.count
    else
      item.children.count
    end
  end

  def render_descendants_count_by_category(item, category)
    if category == 'finance'
      item.descendants.joins(:stocks).finance.uniq.count
    elsif category == 'exclude-finance'
      item.descendants.joins(:stocks).exclude_finance.uniq.count
    else
      item.descendants.uniq.count
    end
  end
end
