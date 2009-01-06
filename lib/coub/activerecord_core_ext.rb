# http://www.intridea.com/2008/2/19/activerecord-base-create_or_update-on-steroids-2
# http://github.com/jeremymcanally/docbox/tree/57215361c3a585a9608bee25cd6e4659c780ff17/lib/core_ext.rb
class << ActiveRecord::Base
  def create_or_update(options = {})
    self.create_or_update_by(:id, options)
  end

  def create_or_update_by(field, options = {})
    find_value = options.delete(field)
    record = find(:first, :conditions => {field => find_value}) || self.new
    record.send field.to_s + "=", find_value
    record.attributes = options
    record.save!
    record
  end
  
  def create_or_update_by_and(field1, field2, options = {})
    find_value1 = options.delete(field1)
    find_value2 = options.delete(field2)
    record = find(:first, :conditions => {field1 => find_value1, field2 => find_value2}) || self.new
    record.send "#{field1.to_s}=", find_value1
    record.send "#{field2.to_s}=", find_value2
    record.attributes = options
    record.save!
    record
  end

  def method_missing_with_create_or_update(method_name, *args, &block)
    if match = method_name.to_s.match(/create_or_update_by_([a-z0-9_]+)/)
      if match[1] =~ /([a-z0-9_]+)_and_([a-z0-9_]+)/
        create_or_update_by_and($1.to_sym, $2.to_sym, *args)
      else
        field = match[1].to_sym
        create_or_update_by(field,*args)
      end
    else
      method_missing_without_create_or_update(method_name, *args, &block)
    end
  end

  alias_method_chain :method_missing, :create_or_update
end
