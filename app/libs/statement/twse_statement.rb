class Statement::TwseStatement

  def initialize(meta)
    raise ArgumentError unless meta.is_a?(Statement::Metadata)
    @meta = meta
  end

  def raw_data
    @raw_data ||= Statement::Downloader.new(meta).data
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

  # private


    def meta
      @meta
    end

    def parse_data
      [bs_table, is_table, cf_table].each_with_index do |table, i|
        parse_table(table, i)
      end
    end

    def parse_table(table, i)
      stack = [find_root_item(i)]
      process_index = 0

      table.css('tr').each do |_tr|
        process_index += 1
        next if process_index <= 2

        tr = TR.new(_tr)
        raise RuntimeError, "depth:\n  last item(#{stack.last.name}): #{stack.last.depth}\n  current(#{tr.name}): #{tr.depth}" if (tr.depth - stack.last.depth).abs > 1

        # current item is a child of previous item
        if tr.depth > stack.last.depth
          item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id, depth: tr.depth)
          stack << item
        # current item is a sibling of previous item
        elsif tr.depth == stack.last.depth
          stack.pop
          item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id, depth: tr.depth)
          stack << item
        # current item is a sibling of the parent of previous item
        elsif tr.depth < stack.last.depth
          stack.pop(2)
          item = Item.find_or_create_by!(name: tr.name, has_value: tr.has_value?, parent_id: stack.last.id, depth: tr.depth)
          stack << item
        else
          raise RuntimeError, "Should not be here"
        end

        create_item_mapping_if_not_exist!(item, tr)
      end
    end

    def create_item_mapping_if_not_exist!(item, tr)
      ItemMapping.find_or_create_by!(
        item_id:           item.id,
        statement_id:      statement.id,
        stock_id:          meta.stock.id,
        stock_exchange_id: statement.stock_exchange_id,
        stock_ticker:      meta.ticker,
        stock_exchange_symbol: statement.stock_exchange_symbol,
        value:             tr.value
      )
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
        @depth ||= tr.children[0].content[/\A　*/].size
        raise "depth should be greater than 0" if @depth < 1
        @depth
      end

      def name
        @name ||= tr.children[0].content.strip.remove(/[　 ]/)
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
    end

end
