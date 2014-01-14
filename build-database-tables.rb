require 'active_record'
require 'data_active'


if ENV['CBDB_EXPORT_DIRECTORY'] == nil
  puts 'You must set CBDB_EXPORT_DIRECTORY to the location ' +
       'holding the access xml files.'
  abort
else
  CBDB_EXPORT_DIRECTORY = ENV['CBDB_EXPORT_DIRECTORY']
end


ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => "cbdb.sqlite3",
)

class NianHao < ActiveRecord::Base
  belongs_to :dynasty
end

class Dynasty < ActiveRecord::Base
end

class GanzhiCode < ActiveRecord::Base
end

class BiogMain < ActiveRecord::Base
end

unless NianHao.table_exists?
  class Schema < ActiveRecord::Migration
    def change
      create_table :nian_haos do |t|
        t.references :c_dy
        t.string :c_dynasty_chn
        t.string :c_nianhao_chn
        t.integer :c_firstyear
        t.integer :c_lastyear
      end

      create_table :dynasties do |t|
        t.string :c_dynasty
        t.string :c_dynasty_chn
        t.integer :c_start
        t.integer :c_end
        t.integer :c_sort
      end

      create_table :ganzhi_code do |t|
        t.string :c_ganzhi_chn
      end

      create_table :biog_mains do |t|
        t.string :c_name
        t.string :c_name_chn
        t.integer :c_birthyear
        t.integer :c_deathyear
        t.string :c_surname
        t.string :c_surname_chn
        t.string :c_mingzi
        t.string :c_mingzi_chn
        t.integer :c_dy
      end
    end
  end

  Schema.new.change
end

#
# Massage access exports
#
# We change the record names and some attributes to confirm to
# rails conventions for table names and associations.
#

File.open(File.join(CBDB_EXPORT_DIRECTORY, 'NIAN_HAO.xml')) do |f|
  contents = f.read
  contents.gsub!('NIAN_HAO', 'nian_hao')
  contents.gsub!('c_dy', 'c_dy_id')

  print "Importing Nianhaos ... "
  NianHao.many_from_xml contents, [:sync]
  puts NianHao.all.count
end

File.open(File.join(CBDB_EXPORT_DIRECTORY, 'DYNASTIES.xml')) do |f|
  contents = f.read
  contents.gsub!('DYNASTIES', 'dynasty')

  print "Importing Dynasties ... "
  Dynasty.many_from_xml contents, [:sync]
  puts Dynasty.all.count
end

File.open(File.join(CBDB_EXPORT_DIRECTORY, 'GANZHI_CODES.xml')) do |f|
  contents = f.read
  contents.gsub!('GANZHI_CODES', 'ganzhi_code')

  print "Importing Ganzhi ... "
  GanzhiCode.many_from_xml contents, [:sync]
  puts GanzhiCode.all.count
end

File.open(File.join(CBDB_EXPORT_DIRECTORY, 'BIOG_MAINaccessdel.xml')) do |f|
  contents = f.read
  contents.gsub!('BIOG_MAIN', 'biog_main')

  print "Importing Biographies ... "
  BiogMain.many_from_xml contents, [:sync]
  puts BiogMain.all.count
end

if nil
nianhaos = NianHao.all
nianhaos.each do |nh|
  puts "#{nh.inspect}"
end

dynasties = Dynasty.all
dynasties.each do |d|
  puts "#{d.inspect}"
end

ganzhi_codes = GanzhiCode.all
ganzhi_codes.each do |d|
  puts "#{d.inspect}"
end
end
