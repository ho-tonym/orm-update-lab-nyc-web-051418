require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade, :id
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
#    binding.pry
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    @id = row[0]
    @name = row[1]
    @grade = row[2]
    new_student = self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(input_name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
    SQL
    student_nested = DB[:conn].execute(sql, input_name)

    id = student_nested[0][0]
    name = student_nested[0][1]
    grade = student_nested[0][2]
    Student.new(name, grade, id)
  end
end
