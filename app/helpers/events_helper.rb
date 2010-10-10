module EventsHelper
  def to_pt_BR_format(datetime)
    datetime.strftime("%d/%m/%Y %H:%M") unless datetime.nil?
  end
end
