class Statement::Downloader

  def initialize(meta)
    raise ArgumentError, "#{meta.class}" unless meta.is_a?(Statement::Metadata)
    @meta = meta
  end

  def data
    @data ||= download_data
  end

  def has_data?
    data.size > 5000 && !data.include?("查無資料")
  end

  def ifrs?
    meta.year >= 2013
  end

  def gaap?
    meta.year < 2013
  end


  private


    def download_data
      tries ||= 3
      resp = RestClient.post(url, form_data)
    rescue => e
      if (tries -= 1) > 0
        sleep 3
        retry
      else
        raise e
      end
    else
      Iconv.conv('utf-8//IGNORE', 'big5', resp)
    end

    def url
      ifrs? ? 'http://mops.twse.com.tw/server-java/t164sb01' : 'http://mops.twse.com.tw/server-java/t147sb02'
    end

    def meta
      @meta
    end

    def form_data
      if ifrs?
        {
          step:       '1',
          DEBUG:      '',
          CO_ID:      meta.ticker,
          SYEAR:      meta.year,
          SSEASON:    meta.quarter,
          REPORT_ID:  meta.consolidated? ? 'C' : 'A'
        }
      else
        {
          step:     '0',
          comp_id:  meta.ticker,
          YEAR1:    meta.year,
          SEASON1:  meta.quarter,
          R_TYPE1:  meta.consolidated? ? 'B' : 'A'
        }
      end
    end
end
