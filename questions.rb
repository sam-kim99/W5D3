require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabaseConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
    attr_accessor :fname, :lname
    def self.find_by_id(id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM users
            WHERE id = ?
        SQL
        debugger
        #[{id => ?}]
        data.map {|datum| User.new(datum)}
        #[?]
        data.first
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end
end

class Question
    attr_accessor :title, :body, :author_id
    def self.find_by_id(id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM questions
            WHERE id = ?
        SQL
        data.map {|datum| Question.new(datum)}
        data.first
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end
end

class QuestionFollow
    attr_accessor :user_id, :question_id
    def self.find_by_id(id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM question_follows
            WHERE id = ?
        SQL
        data.map {|datum| QuestionFollow.new(datum)}
        data.first
    end

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end
end

class Reply
    attr_accessor :parent_reply_id, :question_id, :author_id, :body
    def self.find_by_id(id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM replies
            WHERE id = ?
        SQL
        data.map {|datum| Reply.new(datum)}
        data.first
    end

    def initialize(options)
        @id = options['id']
        @parent_reply_id = options['parent_reply_id']
        @question_id = options['question_id']
        @author_id = options['author_id']
        @body = options['body']
    end
end