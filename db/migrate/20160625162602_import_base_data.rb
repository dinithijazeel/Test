class ImportBaseData < ActiveRecord::Migration
  def change
    # print "-- importing users...\n"
    # import('db/data/users.sql')
    # print "-- importing contacts...\n"
    # import('db/data/contacts.sql')
    # print "-- importing products ...\n"
    # import('db/data/products.sql')
  end

  def import(file)
    sql = File.read(file)
    statements = sql.split(/;$/)
    statements.pop # remote empty line
    ActiveRecord::Base.transaction do
      statements.each do |statement|
        connection.execute(statement)
      end
    end
  end
end
