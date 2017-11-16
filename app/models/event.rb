class Event < ApplicationRecord
  validates :kind, presence: true, inclusion: { in: %w(opening appointment), message: "%{value} is not a valid kind" }
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :starts_at_cannot_be_grather_than_ends_at

  def starts_at_cannot_be_grather_than_ends_at
    if starts_at > ends_at
      errors.add(:starts_at, "cannot be greather than ends_at")
    end
  end


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

    # first the events where weekly_recurring is true
    events_weekly_recurring = Event.where(weekly_recurring: true)
    # add_results(events_weekly_recurring, results)
    add_results(events_weekly_recurring, appointment_duration, date_time, results)

    # second the opening events in the good interval
    events_opening = Event.where(kind: "opening").where("ends_at < ?", date_time + 7.days).where("starts_at > ?", date_time)
    add_results(events_opening, appointment_duration, date_time, results)
    # last we delete when there is an appointment
    events_appointment = Event.where(kind: "appointment").where("ends_at < ?", date_time + 7.days).where("starts_at > ?", date_time)
    delete_results(events_appointment, appointment_duration, date_time, results)

    return results.values
  end


  def self.define_date(date_time, time)
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
  end

  def self.add_results(events, appointment_duration, date_time, results)
    events.each do |event, index|
      (event.starts_at.to_i..event.ends_at.to_i).step(appointment_duration) do |hour, i|
        next if event.ends_at.to_i === hour
        # round the time of appointment
        time = Time.at((hour.to_f / appointment_duration).round * appointment_duration).utc
        wday = Date.new(hour).wday
        date = define_date(date_time, time)
        results[date.strftime("%Y/%m/%d")][:slots].push(time.strftime("%k:%M").strip).uniq!
      end
    end
  end

  def self.delete_results(events, appointment_duration, date_time, results)
    events.each do |event, index|
      (event.starts_at.to_i..event.ends_at.to_i).step(appointment_duration) do |hour, i|
        next if event.ends_at.to_i === hour
        # round the time of appointment
        time = Time.at((hour.to_f / appointment_duration).round * appointment_duration).utc
        wday = Date.new(hour).wday
        date = define_date(date_time, time)
        results[date.strftime("%Y/%m/%d")][:slots].delete(time.strftime("%k:%M").strip)
      end
    end
  end

end
