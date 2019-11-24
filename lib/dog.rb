require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(new_hash)
        @id = new_hash[:id]
        @name = new_hash[:name]
        @breed = new_hash[:breed]
    end
  
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        );
      SQL
      DB[:conn].execute(sql)
    end
  
    def self.drop_table
      sql = <<-SQL
        DROP TABLE dogs;
      SQL
      DB[:conn].execute(sql)
    end
  
    def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]  
      end 
      self
    end

    def self.create(new_hash)
      new_dog = self.new(name: new_hash[:name], breed: new_hash[:breed])
      new_dog.save
      new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end
  
    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      breed = row[2]
      self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ?
          LIMIT 1
        SQL
    
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
    end
  

    def self.find_or_create_by(new_hash)
        check_dog = self.find_by_name(new_hash[:name])
        if check_dog && check_dog.breed == new_hash[:breed]
            dog = check_dog
        else 
            dog = self.create(new_hash)
        end
        dog
    end
  
  
    def update
      sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?; 
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end



end