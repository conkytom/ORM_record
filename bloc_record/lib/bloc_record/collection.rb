module BlocRecord
    class Collection < Array
        def update_all(updates)
            ids = self.map(&:id)
            self.any? ? self.first.class.update(ids, updates) : false
        end
    
        def take(num=1)
            if self.any?
                self[0...num]
            else
                nil 
            end
        end
    
        def where(*args)
            ids = self.map(&:id)
            if args.count > 1
                expression = args.shift
                params = args
            else
                case args.first
                when String
                    expression = args.first
                when Hash
                    expression_hash = BlocRecord::Utility.convert_keys(args.first)
                    expression = expression_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" AND ")
                end
            end
            string = "id IN (#{ids.join ","}) AND #{expression}"
            self.any? ? self.first.class.where(string) : false
        end
    
        def not(*args)
            ids = self.map(&:id)
            if args.count > 1
                expression = args.shift
                params = args
            else
                case args.first
                when String
                    expression = args.first
                when Hash 
                    expression_hash = BlocRecord::Utility.convert_keys(args.first)
                    expression = expression_hash.map { |key, value| "NOT #{key} = #{BlocRecord::Utility.sql_strings(value)}"}.join(" AND ")
                end
            end
            string = "id IN (#{ids.join ","}) AND #{expression}"
            self.any? ? self.first.class.where(string) : false
        end
    end
end
