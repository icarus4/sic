class ParseStatementByStock

  def initialize(stock, types = ['c', 'i'])
    # Iterate statement types
    types.each do |type|
      catch(:no_result) do
        failed_count = 0
        # Iterate years
        Time.zone.now.year.downto(2013) do |year|
          4.downto(1) do |quarter|

            puts "processing stock:#{stock.is_a?(String) ? stock : stock.ticker} type:#{type} year:#{year} quarter:#{quarter}"
            meta = Statement::Metadata.new(stock: stock, year: year, quarter: quarter, type: type)

            statement = Statement.find_by(stock_id: meta.stock.id, year: year, quarter: quarter, statement_type: type)
            next if statement.try(:parsed_at)

            begin
              tries ||= 0
              result = Statement::TwseStatement.new(meta).parse
            rescue => e
              puts "Stop for a while"
              tries += 1
              sleep (30 + tries*10)
              retry if tries < 10
            end

            if result.nil?
              failed_count += 1
              puts "No result, type:#{type} year:#{year} quarter:#{quarter}"
              throw(:no_result) if failed_count > 3
              sleep 2
            end
          end
        end
      end # catch(:no_result) do
    end # ['c', 'i'].each do |type|
  end
end
