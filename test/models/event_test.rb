# test/models/event_test.rb

require 'test_helper'

class EventTest < ActiveSupport::TestCase


  test "Test with Sunday as day week (input)" do

    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-11 15:50"), ends_at: DateTime.parse("2014-08-11 18:30"), weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal ["16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
  end

  test "Test with Sunday as day week (event)" do

    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-10 15:50"), ends_at: DateTime.parse("2014-08-10 18:30"), weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse("2014-08-11")
    assert_equal ["16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[6][:slots]
    assert_equal Date.new(2014, 8, 17), availabilities[6][:date]
  end

  test "Test with Sunday as day week for both" do

    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-10 15:50"), ends_at: DateTime.parse("2014-08-10 18:31"), weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal ["16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
  end



  test "Test with only events weekly recurring" do

    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-10 15:50"), ends_at: DateTime.parse("2014-08-10 18:30"), weekly_recurring: true
    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-05 15:50"), ends_at: DateTime.parse("2014-08-05 18:30"), weekly_recurring: true
    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-06 15:50"), ends_at: DateTime.parse("2014-08-06 18:30"), weekly_recurring: true
    availabilities = Event.availabilities DateTime.parse("2014-08-10")

    assert_equal ["16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]

  end

  test "Test with only opening events" do

    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-10 15:50"), ends_at: DateTime.parse("2014-08-10 18:30")
    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-05 15:50"), ends_at: DateTime.parse("2014-08-05 18:30")
    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-12 15:50"), ends_at: DateTime.parse("2014-08-12 18:30")
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal ["16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal ["16:00", "16:30", "17:00", "17:30", "18:00"], availabilities[2][:slots]
    assert_equal Date.new(2014, 8, 12), availabilities[2][:date]
  end

  test "Test to see if appointment event are filtered" do
    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-10 15:50"), ends_at: DateTime.parse("2014-08-10 18:30")
    Event.create! kind: 'appointment', starts_at: DateTime.parse("2014-08-10 17:50"), ends_at: DateTime.parse("2014-08-10 18:30")
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal ["16:00", "16:30", "17:00"], availabilities[0][:slots]
  end

  test "Test the case where start_at and ends_at not the same day" do
    Event.create! kind: 'opening', starts_at: DateTime.parse("2014-08-04 23:30"), ends_at: DateTime.parse("2014-08-05 03:30"), weekly_recurring: true
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal [], availabilities[0][:slots]
    assert_equal ["23:30"], availabilities[1][:slots]
    assert_equal ["0:00", "0:30", "1:00", "1:30", "2:00", "2:30", "3:00"], availabilities[2][:slots]
  end


  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "one more complicated test example" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-7 09:30"), ends_at: DateTime.parse("2017-11-7 11:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-8 09:30"), ends_at: DateTime.parse("2017-11-8 11:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-9 09:30"), ends_at: DateTime.parse("2017-11-9 11:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-10 09:30"), ends_at: DateTime.parse("2017-11-10 11:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-11 09:30"), ends_at: DateTime.parse("2017-11-11 11:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-12 09:30"), ends_at: DateTime.parse("2017-11-12 11:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-13 09:30"), ends_at: DateTime.parse("2017-11-13 11:30"), weekly_recurring: true

    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-20 12:30"), ends_at: DateTime.parse("2017-11-20 15:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2017-11-20 15:00"), ends_at: DateTime.parse("2017-11-20 15:30")
    availabilities = Event.availabilities DateTime.parse("2017-11-18")

    assert_equal Date.new(2017, 11, 20), availabilities[2][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "12:30", "13:00", "13:30", "14:00", "14:30"], availabilities[2][:slots]

  end

  test "Round correctly for an opening" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-20 12:31"), ends_at: DateTime.parse("2017-11-20 18:00")
    availabilities = Event.availabilities DateTime.parse("2017-11-18")

    assert_equal Date.new(2017, 11, 20), availabilities[2][:date]
    assert_equal ["13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"], availabilities[2][:slots]

  end

  test "Round correctly for an opening 2" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-20 12:31"), ends_at: DateTime.parse("2017-11-20 18:00")
    availabilities = Event.availabilities DateTime.parse("2017-11-18")

    assert_equal Date.new(2017, 11, 20), availabilities[2][:date]
    assert_equal ["13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"], availabilities[2][:slots]

  end


  test "Round correctly for an appointment 1" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-20 12:35"), ends_at: DateTime.parse("2017-11-20 18:31")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2017-11-20 16:20"), ends_at: DateTime.parse("2017-11-20 16:45")
    availabilities = Event.availabilities DateTime.parse("2017-11-18")

    assert_equal Date.new(2017, 11, 20), availabilities[2][:date]
    assert_equal ["13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "17:00", "17:30", "18:00"], availabilities[2][:slots]

  end

  test "Round correctly for an appointment 2" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-20 12:31"), ends_at: DateTime.parse("2017-11-20 18:29")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2017-11-20 16:20"), ends_at: DateTime.parse("2017-11-20 17:00")
    availabilities = Event.availabilities DateTime.parse("2017-11-18")

    assert_equal Date.new(2017, 11, 20), availabilities[2][:date]
    assert_equal ["13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "17:00", "17:30"], availabilities[2][:slots]

  end

  test "Round correctly for an appointment 3" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-20 12:31"), ends_at: DateTime.parse("2017-11-20 18:00")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2017-11-20 15:59"), ends_at: DateTime.parse("2017-11-20 17:00")
    availabilities = Event.availabilities DateTime.parse("2017-11-18")

    assert_equal Date.new(2017, 11, 20), availabilities[2][:date]
    assert_equal ["13:00", "13:30", "14:00", "14:30", "15:00", "17:00", "17:30"], availabilities[2][:slots]

  end

  test "Event where weekly_recurring is true and starts in the future are filtered" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-18 12:31"), ends_at: DateTime.parse("2017-11-18 14:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-20 12:31"), ends_at: DateTime.parse("2017-11-20 14:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-11-26 12:31"), ends_at: DateTime.parse("2017-11-20 14:00"), weekly_recurring: true
    availabilities = Event.availabilities DateTime.parse("2017-11-18")
    assert_equal Date.new(2017, 11, 18), availabilities[0][:date]
    assert_equal ["13:00", "13:30"], availabilities[0][:slots]
    assert_equal Date.new(2017, 11, 19), availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
    assert_equal Date.new(2017, 11, 20), availabilities[2][:date]
    assert_equal ["13:00", "13:30"], availabilities[2][:slots]
  end


  test "Test for december month" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-12-29 09:30"), ends_at: DateTime.parse("2017-12-29 12:30")
    Event.create kind: 'opening', starts_at: DateTime.parse("2018-01-02 09:30"), ends_at: DateTime.parse("2018-01-02 12:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2017-12-29 10:30"), ends_at: DateTime.parse("2017-12-29 11:30")
    availabilities = Event.availabilities DateTime.parse("2017-12-28")
    assert_equal Date.new(2018, 01, 02), availabilities[5][:date]
    assert_equal ["9:30", "10:00", "10:30", "11:00", "11:30", "12:00"], availabilities[5][:slots]
  end

  test "Test for 31th december" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2017-12-31 09:30"), ends_at: DateTime.parse("2017-12-31 12:35")
    Event.create kind: 'opening', starts_at: DateTime.parse("2018-01-02 09:30"), ends_at: DateTime.parse("2018-01-02 12:35")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2017-12-31 10:30"), ends_at: DateTime.parse("2017-12-31 11:30")
    availabilities = Event.availabilities DateTime.parse("2017-12-31")
    assert_equal Date.new(2017, 12, 31), availabilities[0][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[0][:slots]
  end



end
