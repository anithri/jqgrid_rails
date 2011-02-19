module JqGridRails
  module Controller
    
    # These are the valid search operators jqgrid uses
    # and the database translations for them. We use closures
    # for the value so we can modify the string if we see fit
    SEARCH_OPERS = {
      'eq' => ['= ?', lambda{|v| v}],
      'ne' => ['!= ?', lambda{|v|v}],
      'lt' => ['< ?', lambda{|v|v}],
      'le' => ['<= ?', lambda{|v|v}],
      'gt' => ['> ?', lambda{|v|v}],
      'ge' => ['>= ?', lambda{|v|v}],
      'bw' => ['ilike ?', lambda{|v| "#{v}%"}],
      'bn' => ['not ilike ?', lambda{|v| "#{v}%"}],
      'in' => ['in ?', lambda{|v| v.split(',').map(&:strip)}],
      'ni' => ['not in ?', lambda{|v| v.split(',').map(&:strip)}],
      'ew' => ['ilike ?', lambda{|v| "%#{v}"}],
      'en' => ['not ilike ?', lambda{|v| "%#{v}"}],
      'cn' => ['ilike ?', lambda{|v| "%#{v}%"}],
      'nc' => ['not ilike ?', lambda{|v| "%#{v}%"}]
    }

    # klass:: ActiveRecord::Base class or ActiveRecord::Relation
    # params:: Request params
    # fields:: Fields used within grid. Can be an array of attribute 
    #          names or a Hash mapping with the key being the model 
    #          attribute and value being the reference used within the grid
    # Provides generic JSON response for jqGrid requests (sorting/searching)
    def grid_response(klass, params, fields)
      unless((klass.is_a?(Class) && klass.ancestors.include?(ActiveRecord::Base)) || klass.is_a?(ActiveRecord::Relation))
        raise TypeError.new "Unexpected type received. Allowed types are Class or ActiveRecord::Relation. Received: #{klass.class}"
      end
      rel = apply_sorting(klass, params, fields)
      rel = apply_searching(rel, params, fields)
      hash = create_result_hash(rel, fields)
      hash.to_json
    end

    # klass:: ActiveRecord::Base class or ActiveRecord::Relation
    # params:: Request params
    # fields:: Fields used within grid
    # Applies any sorting to result set
    def apply_sorting(klass, params, fields)
      sort_col = params[[:sidx, :searchField].find{|sym| !params[:sym].blank?}]
      unless(sort_col)
        check = nil
        case fields
          when Hash
            sort_col = fields.detect{|k,v| v.to_s == params[:sidx]}.try(:first)
          when Array
            sort_col = params[:sidx] if fields.map(&:to_s).include?(params[:sidx])
        end
      end
      unless(sort_col)
        sort_col = fields.is_a?(Array) ? fields.first : fields.keys.first
      end
      sort_ord = params[:sord] == 'asc' ? 'ASC' : 'DESC'
      klass.order("#{klass.table_name}.#{sort_col} #{sort_ord}")
    end
    
    # klass:: ActiveRecord::Base class or ActiveRecord::Relation
    # params:: Request params
    # fields:: Fields used within grid
    # Applies any search restrictions to result set
    def apply_searching(klass, params, fields)
      unless(params[:searchField].blank?)
        search_field = params[:searchField]
        search_oper = params[:searchOper]
        search_string = params[:searchString]
        raise ArgumentError.new("Invalid search operator received: #{params[:searchOper]}") unless SEARCH_OPERS.keys.include?(search_oper)
        klass.where([
          "#{search_field} #{SEARCH_OPERS[search_oper].first}",
          SEARCH_OPERS[search_oper].last.call(search_string)
        ])
      else
        klass
      end
    end

    # klass:: ActiveRecord::Base class or ActiveRecord::Relation
    # fields:: Fields used within grid
    # Creates a result Hash in the structure the grid is expecting
    def create_result_hash(klass, fields)
      dbres = klass.paginate(
        :page => params[:page], 
        :per_page => params[:rows]
      )
      res = {'total' => dbres.total_pages, 'page' => dbres.current_page, 'records' => dbres.total_entries}
      calls = fields.is_a?(Array) ? fields : fields.is_a?(Hash) ? fields.keys : nil
      maps = fields.is_a?(Hash) ? fields : nil
      res['rows'] = dbres.map do |row|
        hsh = {}
        calls.each do |method|
          if(row.respond_to?(method.to_sym))
            hsh[maps ? maps[method] : method] = row.send(method.to_sym).to_s
          end
        end
        hsh
      end
      res
    end
  end
end