require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    if @columns.nil?
      columns = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      @columns = columns[0].map { |ele| ele.to_sym }
    else
      @columns
    end
  end

  def self.finalize!
      self.columns.each do |column_name|
        define_method("#{column_name}") do 
          self.attributes[column_name]
        end
        define_method("#{column_name}=") do |value|
          self.attributes[column_name] = value
        end
      end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = "#{table_name.downcase}s"
  end

  def self.table_name
    # ...
    @table_name = "#{self.to_s.downcase}s"
  end

  def self.all
    # ...
    data = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    parse_all(data)
    
  end

  def self.parse_all(results)
    # ...
    parse = []
    results.each { |result| parse << self.new(result)}
    parse
  end

  def self.find(id)
    # ...
    self.all.find { |obj| obj.id == id }
  end

  def initialize(params = {})
    # ...
    
    params.each do |attr_name, val|
      raise "unknown attribute '#{attr_name}'" unless self.methods.include?(attr_name.to_sym)
      self.send("#{attr_name}=", val)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map { |el| self.send(el) }

  end

  def insert
    # ...
    vals = []
    until vals.length == self.attribute_values.length
      vals << "?"
    end
    cols = self.class.columns.join(", ")
    DBConnection.execute(<<-SQL, *self.attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{cols})
    VALUES
      (#{vals.join(", ")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
