class Statement::TwseStatement

  def initialize(meta)
    raise ArgumentError unless meta.is_a?(Statement::Metadata)
    @meta = meta
    @items = []
  end

  def raw_data
    @raw_data ||= downloader.data
  end

  def statement
    @statement ||= ::Statement.find_or_create_by!(
      stock_id: meta.stock.id,
      stock_ticker: meta.ticker,
      stock_exchange_id: meta.stock.stock_exchange.id,
      stock_exchange_symbol: meta.stock.stock_exchange_symbol,
      statement_type: meta.type,
      year: meta.year,
      quarter: meta.quarter
    )
  end

  def parse
    parse_data
  end

  def items
    @items
  end

  private


    def downloader
      @downloader ||= Statement::Downloader.new(meta)
    end

    def meta
      @meta
    end

    def parse_data
      return nil unless downloader.has_data?

      if downloader.ifrs?
        [bs_table, is_table, cf_table].each_with_index do |table, i|
          parse_ifrs_table(table, i)
        end
      elsif downloader.gaap?
        parse_gaap_table
      end

      statement.parsed_at = Time.zone.now
      statement.save!

      return statement, @items
    end

    def parse_ifrs_table(table, i)
      stack = [find_root_item(i)]
      process_index = 0

      table.css('tr').each do |_tr|
        # Skip 會計項目 & 資產負債表/損益表/現金流量表
        process_index += 1
        next if process_index <= 2

        tr = TR.new(_tr)

        depth_diff = tr.depth - stack.last.depth
        # current item is a child of previous item
        if depth_diff == 1
          item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id)
          stack << item
        # current item is a sibling of previous item
        elsif depth_diff == 0
          stack.pop
          item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id)
          stack << item
        # current item is a sibling of previous item's parent
        elsif depth_diff == -1 || depth_diff == -2
          stack.pop(depth_diff.abs + 1)
          item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id)
          stack << item
        else
          raise RuntimeError, "ticker:#{meta.ticker} year:#{meta.year} quarter:#{meta.quarter} type:#{meta.type}\ndepth:\n  last item(#{stack.last.name}): #{stack.last.depth}\n  current(#{tr.name}): #{tr.depth}" if (tr.depth - stack.last.depth).abs > 1
        end

        @items << item
        create_item_mapping_if_not_exist!(item, tr)
      end
    end

    def parse_gaap_table
      stack = []
      gaap_table.css('tr').each do |_tr|
        tr = TR.new(_tr)
        next if tr.name == '會計科目'

        if tr.name == '資產負債表' || tr.name == '損益表' || tr.name == '現金流量表'
          # In order to compatible with IFRS, we change '損益表' to '綜合損益表'
          name = tr.name
          name = '綜合損益表' if tr.name == '損益表'
          item = Item.find_by!(name: name, has_value: tr.has_value?, parent_id: nil)
          stack.clear
          stack << item
          next
        else
          depth_diff = tr.depth - stack.last.depth
          # current item is a child of previous item
          if depth_diff == 1
            item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id)
            stack << item
          # current item is a sibling of previous item
          elsif depth_diff == 0
            stack.pop
            item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id)
            stack << item
          # current item is a sibling of previous item's parent
          elsif depth_diff == -1 || depth_diff == -2
            stack.pop(depth_diff.abs + 1)
            item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id)
            stack << item
          else
            raise RuntimeError, "ticker:#{meta.ticker} year:#{meta.year} quarter:#{meta.quarter} type:#{meta.type}\ndepth:\n  last item(#{stack.last.name}): #{stack.last.depth}\n  current(#{tr.name}): #{tr.depth}" if (tr.depth - stack.last.depth).abs > 1
          end

          @items << item
          create_item_mapping_if_not_exist!(item, tr)
        end
      end
    end

    def create_item_mapping_if_not_exist!(item, tr)
      im = ItemMapping.find_or_initialize_by(item_id: item.id, statement_id: statement.id)
      im.stock_id              = meta.stock.id
      im.stock_exchange_id     = statement.stock_exchange_id
      im.stock_ticker          = meta.ticker
      im.stock_exchange_symbol = statement.stock_exchange_symbol
      im.value                 = tr.value
      im.save!
    end

    def bs_table
      @bs_table ||= nokogiri_doc.css('html body center table')[1]
    end

    def is_table
      @is_table ||= nokogiri_doc.css('html body center table')[2]
    end

    def cf_table
      @cf_table ||= nokogiri_doc.css('html body center table')[3]
    end

    def gaap_table
      @gaap_table ||= nokogiri_doc.css('table.result_table')[0]
    end

    def nokogiri_doc
      @nokogiri_doc ||= Nokogiri::HTML(raw_data)
    end

    def find_root_item(i)
      @root_items ||= [Item.find_by!(name: '資產負債表'), Item.find_by!(name: '綜合損益表'), Item.find_by!(name: '現金流量表')]
      @root_items[i]
    end


    class TR
      def initialize(tr)
        @tr = tr
      end

      def depth
        raise RuntimeError if tr.children.size < 3
        return @depth if @depth

        depth = fullwidth_whitespace_count(tr.children[0].content)

        if depth < 1 && (name != '資產負債表' && name != '綜合損益表' && name != '損益表' && name != '現金流量表')
          depth = halfwidth_whitespace_count(tr.children[0].content) / 4
        end

        @depth = depth
      end

      def name
        @name ||= tr.children[0].content.strip.remove(/[　[[:space:]]]/) # Remove 全/半形空白與 &nbsp
      end

      def value
        @value ||= parse_value
      end

      def has_value?
        value.present?
      end


      private


        def parse_value
          value = tr.children[1].text.strip.remove(',')

          return nil if value.blank?

          if value.is_integer?
            value.to_i
          elsif value.is_number?
            value.to_f
          end
        end

        def tr
          @tr
        end

        def fullwidth_whitespace_count(content)
          content[/\A　*/].size
        end

        def halfwidth_whitespace_count(content)
          content[/\A[[:space:]]*/].size
        end
    end

end
