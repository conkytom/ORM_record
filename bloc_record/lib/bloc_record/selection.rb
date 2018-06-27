require 'sqlite3'

module Selection
    def find(*ids)

        ids.each do |id|
            number_check(id)
        end

        if ids.length == 1
            find_one(ids.first)
        else
            rows = connection.execute <<-SQL
                SELECT #{columns.join ","} FROM #{table}
                WHERE id IN (#{ids.join(",")});
            SQL

            rows_to_array(rows)
        end
    end

    def find_one(id)
        
        number_check(id)

        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            WHERE id = #{id};
        SQL

        init_object_from_row(row)
    end

    def find_by(attribute, value)
        rows = connection.execute <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
        SQL

        rows_to_array(rows)
    end

    def take(num=1)

        number_check(num)

        if num > 1
            rows = connection.execute <<-SQL
                SELECT #{columns.join ","} FROM #{table}
                ORDER BY random()
                LIMIT #{num};
            SQL

            rows_to_array(rows)
        else
            take_one
        end
    end

    def take_one
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY random()
            LIMIT 1;
        SQL

        init_object_from_row(row)
    end

    def first
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY id ASC LIMIT 1;
        SQL

        init_object_from_row(row)
    end

    def last
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY id DESC LIMIT 1;
        SQL

        init_object_from_row(row)
    end

    def all
        rows = connection.execute <<-SQL
            SELECT #{columns.join ","} FROM #{table};
        SQL

        rows_to_array(rows)
    end
    
    def number_check(num)
        unless num.is_a? Integer && num > 0
            raise ArgumentError.new('You must use a positive integer for that')
        end
    end

    def method_missing(m, *args, &block)
        if m[0..7] == "find_by_"
           attribute = m[8...m.length] 
           find_by(attribute, args[0])
        else
            puts " '.#{m}' is not properly defined method.  Please try something else."
        end
    end


    def find_each(options)
        rows = connection.execute <<-SQL
            SELECT #{column.join(",")} FROM #{table}
            ORDER BY id ASC
            LIMIT #{options[:batch_size]} 
            OFFSET #{options[:start]}
        SQL

        for rows in rows_to_array(rows)
            yield row
        end
    end

    def find_in_batches
        rows = connection.execute <<-SQL
            SELECT #{column.join(",")} FROM #{table}
            ORDER BY id ASC
            LIMIT #{options[:batch_size]} 
            OFFSET #{options[:start]}
        SQL

        yield rows_to_array(rows)
    end

    private
    def init_object_from_row(row)
        if row
            data = Hash[columns.zip(row)]
            new(data)
        end
    end

    def rows_to_array(rows)
        rows.map { |row| new(Hash[columns.zip(row)]) }
    end
end
