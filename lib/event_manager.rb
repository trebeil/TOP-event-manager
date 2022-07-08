require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0').slice(0,5)
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyCoeNDIa1--MQOdFaKxJd_VwosWYdaj2Vg'
  
  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,final_template)
  Dir.mkdir('output') unless Dir.exist?('output')

  File.open("output/thanks_#{id}.html", 'w') {|file| file.puts final_template}
end

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

def peak_registration_hours(hours)
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
  hash.each { |k, v| puts "- Between #{k} and #{k + 1} hours: #{v} registrations" if v == max_value }
end

def peak_registration_weekdays(days)
  hash = days.reduce(Hash.new(0)) do |acc, day|
    acc[day] += 1
    acc
  end
  max_value = hash.values.max
  puts 'The days of the week in which most people registered are:'
  hash.each { |k, v| puts "- #{k}: #{v} registrations" if v == max_value }
end

puts 'EventManager initialized'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template = ERB.new(File.read('form_letter.erb'))

hours = []

days = []

contents.each do |row|
  id = row[0]

  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)
  
  final_template = template.result(binding)

  save_thank_you_letter(id, final_template)

  hours[id.to_i - 1] = Time.strptime(row[:regdate],"%m/%d/%y %H:%M").hour

  days[id.to_i - 1] = Time.strptime(row[:regdate],"%m/%d/%y %H:%M").strftime("%A")
end

peak_registration_hours(hours)

puts

peak_registration_weekdays(days)
