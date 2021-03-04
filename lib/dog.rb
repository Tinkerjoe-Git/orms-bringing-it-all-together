class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(attributes)
        @name=attributes[:name]
        @breed=attributes[:breed]
        @id=attributes[:id]
    end

    def self.create_table
        sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.find_by_id(id)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?
          LIMIT 1
        SQL
        DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
        end.first
    end

    def self.drop_table
        sql =  <<-SQL
          DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save 
        if self.id
            update
        else
            sql =  <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.new_from_db(row)
        hash={}
        hash[:id]=row[0]
        hash[:name]=row[1]
        hash[:breed]=row[2]
        Dog.new(hash)
    end

    def self.create(attributes)
        dog=Dog.new(attributes)
        dog.save
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(attributes)
        dogs_data = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{attributes[:name]}' AND breed = '#{attributes[:breed]}'")
        if !dogs_data.empty?
            id, name, breed = dogs_data[0]
            dog = Dog.new(id: id, name: name, breed: breed)
        else
            dog = self.create(attributes)
        end
        dog
    end
end
    

    # def self.find_or_create_by()
    #     dog=self.find_by_name(name)
    #     if dog ==nil
    #       dog=self.create(name)
    #     end
    #     dog
    # end




