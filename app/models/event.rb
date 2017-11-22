class Event < ApplicationRecord
  validates :kind, presence: true, inclusion: { in: %w(opening appointment), message: "%{value} is not a valid kind" }
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :starts_at_cannot_be_grather_than_ends_at, :weekly_recurring_have_to_be_false_if_appointment


  def weekly_recurring_have_to_be_false_if_appointment
    if kind == "appointment" and weekly_recurring == true
      errors.add(:weekly_recurring, "cannot be true")
    end
  end

  def starts_at_cannot_be_grather_than_ends_at
    if starts_at > ends_at
      errors.add(:starts_at, "cannot be greather than ends_at")
    end
  end


  def self.availabilities(date_time_input = DateTime.now)
    raise Exception.new("Bad type of input") if !date_time_input.is_a?(DateTime)
    # initialization
    availabilities = {}
    7.times.each do |i|
      date = date_time_input + i.days
      availabilities[date.strftime("%Y/%m/%d")] = {
        date: date.to_date,
        slots: []
      }
    end
    # an appointment duration is 30 minutes
    appointment_duration = 3600/2

    # first the events where weekly_recurring is true
    events_weekly_recurring = Event.where(weekly_recurring: true).where("starts_at < ?", date_time_input + 1.days)
    add_availabilities(events_weekly_recurring, appointment_duration, date_time_input, availabilities)

    # second the opening events in the good intervall
    events_opening = Event.where(kind: "opening").where("ends_at < ?", date_time_input + 7.days).where("starts_at > ?", date_time_input)
    add_availabilities(events_opening, appointment_duration, date_time_input, availabilities)

    # last we delete when there is an appointment
    events_appointment = Event.where(kind: "appointment").where("ends_at < ?", date_time_input + 7.days).where("starts_at > ?", date_time_input)
    delete_availabilities(events_appointment, appointment_duration, date_time_input, availabilities)
    return availabilities.values
  end


  def self.define_date_event(date_time_input, time)
      # If it's Sunday (Date.commercial which don't accept 0)
    if time.wday == 0
      Date.commercial(date_time_input.to_date.cwyear, date_time_input.to_date.cweek, 7)
      # If it's a day week before the day week input, add a week
    elsif date_time_input.to_date.wday == 0 or time.wday < date_time_input.to_date.wday
      # If it's the latest week of the year
      if date_time_input.to_date.cweek == 52
        Date.commercial(date_time_input.to_date.cwyear + 1, 1, time.wday)
      else
        Date.commercial(date_time_input.to_date.cwyear, date_time_input.to_date.cweek + 1, time.wday)
      end
    else
      Date.commercial(date_time_input.to_date.cwyear, date_time_input.to_date.cweek, time.wday)
    end
  end

  def self.add_availabilities(events, appointment_duration, date_time_input, availabilities)
    events.each do |event|
      events_with_steps = []
      (event.starts_at.to_i..event.ends_at.to_i).step(appointment_duration) do |hour|
        events_with_steps << hour
      end
      events_with_steps.each_with_index do |hour, i|
        # round to superior
        time = Time.at((hour.to_f / appointment_duration).ceil * appointment_duration).utc
        # next the last
        next if events_with_steps.length == i + 1
        # if penultimate
        if events_with_steps.length  === i + 2
          # if you don't have the time for one more appointment, next
          next if Time.at(((hour.to_f / appointment_duration).ceil + 1) * appointment_duration).utc > event.ends_at
        end

        date_event = define_date_event(date_time_input, time)
        availabilities[date_event.strftime("%Y/%m/%d")][:slots].push(time.strftime("%k:%M").strip).uniq!
      end
    end
  end

  def self.delete_availabilities(events, appointment_duration, date_time_input, availabilities)
    events.each do |event|
      events_with_steps = []
      (event.starts_at.to_i..event.ends_at.to_i).step(appointment_duration) do |hour|
        events_with_steps << hour
      end
      events_with_steps.each_with_index do |hour, i|
        # round to inferior the time
        time = Time.at(((hour.to_f / appointment_duration).floor) * appointment_duration).utc
        # particular case if the appointment finishes exactly at the final step
        next if event.ends_at == time
        date_event = define_date_event(date_time_input, time)
        availabilities[date_event.strftime("%Y/%m/%d")][:slots].delete(time.strftime("%k:%M").strip)
      end

      # check if the appointment goes after the limit
      time_end = Time.at(((event.ends_at.to_i.to_f / appointment_duration).floor)* appointment_duration).utc
      if time_end != event.ends_at
        # delete the round to inferior
        date_event = define_date_event(date_time_input, time_end)
        availabilities[date_event.strftime("%Y/%m/%d")][:slots].delete(time_end.strftime("%k:%M").strip)
      end

    end
  end

end
