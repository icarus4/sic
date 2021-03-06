class ParseStatementByStock

  def initialize(stock, types = ['c', 'i'])
    # Iterate statement types
    types.each do |type|
      catch(:no_result) do
        failed_count = 0
        # Iterate years
        Time.zone.now.year.downto(2009) do |year|
          4.downto(1) do |quarter|

            meta = Statement::Metadata.new(stock: stock, year: year, quarter: quarter, type: type)
            puts "processing stock:#{meta.ticker} id:#{meta.stock.id} type:#{type} year:#{year} quarter:#{quarter}"

            statement = Statement.find_by(stock_id: meta.stock.id, year: meta.year, quarter: meta.quarter, statement_type: meta.type)
            next if statement.try(:parsed_at)

            begin
              tries ||= 0
              twse_statement = Statement::TwseStatement.new(meta)
              result = twse_statement.parse
            rescue ActiveRecord::RecordInvalid, DepthDiffError, TrFormatError => e
              ErrorLog.create(data: { meta: meta.inspect, statement: twse_statement.statement.inspect, exception: e.inspect, backtrace: e.backtrace } )
              next
            rescue => e
              puts "Stop for a while"
              tries += 1
              ErrorLog.create(data: { meta: meta.inspect, statement: twse_statement.statement.inspect, exception: e.inspect, backtrace: e.backtrace } )
              sleep (30 + tries*10)
              retry if tries < 5
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
