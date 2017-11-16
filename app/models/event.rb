class Event < ApplicationRecord
  # validate that ends_at
  validates :kind, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  def self.availabilities(date_time = DateTime.now)
    raise Exception.new("Bad type of input") if !date_time.is_a?(DateTime)
    # initialization
    results = {}
    7.times.each do |i|
      date = date_time + i.days
      results[date.strftime("%Y/%m/%d")] = {
        date: date.to_date,
        slots: []
      }
    end
    # an appointment duration is 30 minutes
    appointment_duration = 3600/2

    @events_weekly_recurring = Event.where(weekly_recurring: true)
    @events_weekly_recurring.each do |event, index|
      (event.starts_at.to_i..event.ends_at.to_i).step(appointment_duration) do |hour, i|
        next if event.ends_at.to_i === hour

        # round the time of appointment
        time = Time.at((hour.to_f / appointment_duration).round * appointment_duration).utc
        wday = Date.new(hour).wday
        date =
          if time.wday === 0 and date_time.to_date.wday == 0
            Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, 7)
          elsif time.wday === 0
            Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, 7)
          elsif date_time.to_date.wday == 0
            if date_time.to_date.cweek === 52
              Date.commercial(date_time.to_date.cwyear + 1, 1, time.wday)
            else
              Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek + 1, time.wday)
            end
          elsif time.wday < date_time.to_date.wday
            if date_time.to_date.cweek === 52
              Date.commercial(date_time.to_date.cwyear + 1, 1, time.wday)
            else
              Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek + 1, time.wday)
            end
          else
            Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, time.wday)
          end
        results[date.strftime("%Y/%m/%d")][:slots].push(time.strftime("%k:%M").strip).uniq!

      end
    end

    @events_opening = Event.where(kind: "opening").where("ends_at < ?", date_time + 7.days).where("starts_at > ?", date_time)
    @events_opening.each do |event, index|
      slots = []
      (event.starts_at.to_i..event.ends_at.to_i).step(appointment_duration) do |hour, i|
        next if event.ends_at.to_i === hour
        # round the time of appointment
        time = Time.at((hour.to_f / appointment_duration).round * appointment_duration).utc
        wday = Date.new(hour).wday
        date =
        if time.wday === 0 and date_time.to_date.wday == 0
          Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, 7)
        elsif time.wday === 0
          Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, 7)
        elsif date_time.to_date.wday == 0
          if date_time.to_date.cweek === 52
            Date.commercial(date_time.to_date.cwyear + 1, 1, time.wday)
          else
            Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek + 1, time.wday)
          end
        elsif time.wday < date_time.to_date.wday
          if date_time.to_date.cweek === 52
            Date.commercial(date_time.to_date.cwyear + 1, 1, time.wday)
          else
            Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek + 1, time.wday)
          end
        else
          Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, time.wday)
        end
        results[date.strftime("%Y/%m/%d")][:slots].push(time.strftime("%k:%M").strip).uniq!

      end
    end
    @events_appointment = Event.where(kind: "appointment").where("ends_at < ?", date_time + 7.days).where("starts_at > ?", date_time)
    @events_appointment.each do |event, index|
      slots = []
      (event.starts_at.to_i..event.ends_at.to_i).step(appointment_duration) do |hour, i|

        next if event.ends_at.to_i === hour
        # round the time of appointment
        time = Time.at((hour.to_f / appointment_duration).round * appointment_duration).utc
        wday = Date.new(hour).wday
        date =
        if time.wday === 0 and date_time.to_date.wday == 0
          Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, 7)
        elsif time.wday === 0
          Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, 7)
        elsif date_time.to_date.wday == 0
          if date_time.to_date.cweek === 52
            Date.commercial(date_time.to_date.cwyear + 1, 1, time.wday)
          else
            Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek + 1, time.wday)
          end
        elsif time.wday < date_time.to_date.wday
          if date_time.to_date.cweek === 52
            Date.commercial(date_time.to_date.cwyear + 1, 1, time.wday)
          else
            Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek + 1, time.wday)
          end
        else
          Date.commercial(date_time.to_date.cwyear, date_time.to_date.cweek, time.wday)
        end
        results[date.strftime("%Y/%m/%d")][:slots].delete(time.strftime("%k:%M").strip)

      end
    end
    p results.values
    return results.values
  end


end
