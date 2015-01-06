class Event
  class Recurrence
    include Mongoid::Document

    field :start_date, type: Date
    field :end_date, type: Date
    field :weekdays, type: Array, default: -> { (0..6).to_a }
    field :start_time, type: Integer, default: 0
    field :end_time, type: Integer, default: (24.hours - 1.second)
    field :all_day, type: Boolean, default: false
    field :time_zone, type: String, default: 'UTC'

    embedded_in :event

    def dates
      (start_date.to_date..end_date.to_date).select do |date|
        weekdays.include? date.wday
      end
    end

    def times
      dates.map do |date|
        end_date = end_time < start_time ? date + 1.day : date
        build_date(date, start_time)..build_date(end_date, end_time)
      end
    end

    def start_date
      super.try :in_time_zone, time_zone
    end

    def start_date=(date)
      super Date.parse(date.to_s).in_time_zone(time_zone)
      self.weekdays = [start_date.wday] if one_day?
    end

    def end_date
      if (date = super).nil?
        nil
      else
        date.in_time_zone(time_zone).end_of_day
      end
    end

    def end_date=(date)
      super Date.parse(date.to_s).in_time_zone(time_zone)
      self.weekdays = [start_date.wday] if one_day?
    end

    def time_zone=(time_zone)
      super
      self.start_date = start_date if start_date?
      self.end_date = end_date if end_date?
    end

    private

    # Rebuild the time or times will be out on Daylight Saving switch days
    def build_date(date, time)
      zone.local(
        date.year,
        date.month,
        date.day,
        time / 1.hour,
        (time % 1.hour) / 1.minute,
        time % 1.minute
      )
    end

    def zone
      ActiveSupport::TimeZone[time_zone]
    end

    def one_day?
      return false if start_date.nil? || end_date.nil?

      start_date.to_date == end_date.to_date
    end
  end
end
