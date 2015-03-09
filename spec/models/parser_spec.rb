require 'rails_helper'

RSpec.describe Parser, type: :model do
  
	let (:valid_notam) { 'B0519/15 NOTAMN
Q) ESAA/QFAAH/IV/NBO/A /000/999/5746N01404E005
A) ESGJ B) 1502271138 C) 1503012359
E) AERODROME HOURS OF OPS/SERVICE MON-WED 0500-1830 THU 0500-2130
FRI
0730-2100 SAT 0630-0730, 1900-2100 SUN CLOSED
CREATED: 27 Feb 2015 11:40:00
SOURCE: EUECYIYN'}

	let (:invalid_notam) { 'B0517/15 NOTAMN
Q) ESAA/QSTAH/IV/BO /A /000/999/5746N01404E005
A) ESGJ B) 1502271133 C) 1503012359
E) AERODROME CONTROL TOWER (TWR) HOURS OF OPS/SERVICE MON-THU
0000-0100, 0500-2359 FRI 0000-0100, 0730-2100 SAT 0630-0730,
1900-2100 SUN 2200-2359
CREATED: 27 Feb 2015 11:35:00
SOURCE: EUECYIYN
'}

  it "parse a valid notam" do
    parser = Parser.new(valid_notam)
    parser.run
    expect(parser.parsed_data).to eq([{"ICAO"=>["ESGJ"], "Monday"=>["0500-1830"], "Tuesday"=>["0500-1830"], "Wednesday"=>["0500-1830"], "Thursday"=>["0500-2130"], "Friday"=>["0730-2100"], "Saturday"=>["0630-0730", "1900-2100"], "Sunday"=>["CLOSED"]}])
  end

  it "parse an invalid notam" do
  	parser = Parser.new(invalid_notam)
    parser.run
    expect(parser.parsed_data.count).to eq(0)
  end

  it "parse the entire sample file" do
    parser = Parser.new(IO.read(File.join(Rails.root, 'spec','models',"sample_data.txt")))
    parser.run
    expect(parser.parsed_data.count).to eq(10)
  end
end
