require 'date'
require 'builder'

class Parser
    attr_accessor :raw_data, :parsed_data
    
    REGEXES = { 
        block: /^[\S\s]*A\)\s(?<icao>.*)\sB\)[\S\s]*E\)\ AERODROME HOURS OF OPS\/SERVICE\.?(?<openings>[\S\s]*)CREATED:/,
        openings: /(?<days>[A-Z]{3}\-[A-Z]{3}|[A-Z]{3})\s*(?<hours>(\d{4}\-\d{4},?\s?)+|CLOSED|CLSD)/,
        block_delimiter: /$\s+$/,
        hours_delimiter: /,\s*|\s+/
    }
    
    def initialize raw_data
        self.raw_data = raw_data
    end
    
    def run 
        self.parsed_data = raw_data.split(REGEXES[:block_delimiter]).reduce([]) do |array,block|
            array << parse_block(block) unless parse_block(block).nil?
            array
        end
    end

    def to_html_table
        return "No relevant data found" if self.parsed_data.empty? 
        xm = Builder::XmlMarkup.new(:indent => 2)
        xm.table(class:"table table-striped") {
          xm.thead { xm.tr { self.parsed_data[0].keys.each { |key| xm.th(key)}}}
          xm.tbody { self.parsed_data.each { |row| xm.tr { row.values.each { |value| xm.td(value.join(" | "))}}}}
        }
    end
    
    private

    def parse_block block
        matches = block.match(REGEXES[:block])
        {"ICAO" => [matches[:icao]]}.merge(parse_openings(matches[:openings])) if matches
    end
    
    def parse_openings openings
        result_hash = {}
        openings.scan(REGEXES[:openings]) do |days,hours|
            days_number = days.split("-").map { |wd| DateTime.parse(wd).cwday }
            Range.new(days_number.min,days_number.max).to_a.reduce(result_hash) {|r,n| r[Date::DAYNAMES[n%7]] = hours.split(REGEXES[:hours_delimiter]) ; r} 
        end
        result_hash
    end
end