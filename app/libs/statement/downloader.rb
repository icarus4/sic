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
      meta.year >= 2013 ? 'http://mops.twse.com.tw/server-java/t164sb01' : (raise NotImplementedError)
    end

    def meta
      @meta
    end

    def form_data
      {
        step:       '1',
        DEBUG:      '',
        CO_ID:      meta.ticker,
        SYEAR:      meta.year,
        SSEASON:    meta.quarter,
        REPORT_ID:  meta.consolidated? ? 'C' : 'A'
      }
    end
end
