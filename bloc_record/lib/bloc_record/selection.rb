require 'sqlite3'

module Selection
    def find(id)
        row = connection.get_first_row <<-SQL
            SELECT
            WHERE id = 
        SQL

        data = Hash[columns.zip(row)]
        new(data)
    end
end
