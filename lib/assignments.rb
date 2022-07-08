require 'csv'
require 'time'

def clean_phone_numbers(number_string)
  phone_number = number_string.delete('(').delete(')').delete('-').delete('.').delete(' ')
  length = phone_number.length
  phone_number = if length == 10
                phone_number.insert(3,'-').insert(7,'-')
              elsif length == 11
                if phone_number.chars[0] == "1"
                  phone_number[1..-1].insert(3,'-').insert(7,'-')
                else
                  'No phone number available'
                end
              else
                'No phone number available'
              end
end

csv = CSV.open('event_attendees.csv',
        headers: true,
        header_converters: :symbol
      )
hours = []
days = []

csv.each do |row|
  hours[row[0].to_i - 1] = Time.strptime(row[:regdate],"%m/%d/%y %H:%M").hour
  days[row[0].to_i - 1] = Time.strptime(row[:regdate],"%m/%d/%y %H:%M").strftime("%A")
end

p days
gets

hash = days.reduce(Hash.new(0)) do |acc, day|
  acc[day] += 1
  acc
end
max_value = hash.values.max
puts 'The days of the week in which most people registered are:'
hash.each { |k, v| puts "- #{k}: #{v} registrations" if v == max_value }

gets

hash = hours.reduce(Hash.new(0)) do |acc, hour|
  if acc[hour] == nil
    acc[hour] = 1
  else
    acc[hour] += 1
  end
  acc
end
max_value = hash.values.max
puts 'The hours of the day in which most people registered are:'
hash.each { |k, v| puts "- Between #{k} and #{k + 1} hours" if v == max_value }