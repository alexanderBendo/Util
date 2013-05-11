#!/usr/bin/env ruby

#
# Export data from the JEFIT Android App database to CSV
#

require 'csv'
require 'sqlite3'

cols = %W(Date Exercise TotalVolume TotalReps RawLog)
data = []

begin

    db = SQLite3::Database.open "jefit.sqlite"
    db.results_as_hash = true
    sth = db.prepare "select  * from exerciseLogs"
    rs = sth.execute

    rs.each do |row|

        total_ex_reps = 0
        total_ex_vol  = 0

        row['logs'].split(",").each do |set|

            weight, reps = set.split("x")

            # This is for exercises which are performed just for reps (for
            # example bodyweight exercises)
            # Set weight to 1 for you can somehow calculate volume

            weight = weight.to_i.equal?(0) ? 1 : weight

            total_ex_reps += reps.to_i
            total_ex_vol += reps.to_i * weight.to_i

        end

        data << [row['mydate'], row['ename'], total_ex_vol, total_ex_reps, row['logs']]

    end

rescue SQLite3::Exception => e

    puts "Exception!"
    puts e

end

csv = CSV.open('jefit.csv', 'w', {:col_sep => ";"})

csv << cols

data.each do |row|
    csv << row
end
