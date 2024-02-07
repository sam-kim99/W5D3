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
    attr_reader :id
    attr_accessor :fname, :lname
    def self.find_by_id(id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM users
            WHERE id = ?
        SQL
        data.map! {|datum| User.new(datum)}
        data.first
    end

    def self.find_by_name(fname, lname)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, fname, lname)
            SELECT * 
            FROM users
            WHERE fname = ? AND lname = ?
        SQL
        data.map! {|datum| User.new(datum)}
        data.first
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        Question.find_by_author_id(id)
    end

    def authored_replies
        Reply.find_by_author_id(id)
    end

    def followed_questions
        QuestionFollow.followed_for_user_id(id)
    end
end

class Question
    attr_reader :id
    attr_accessor :title, :body, :author_id
    def self.find_by_id(id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM questions
            WHERE id = ?
        SQL
        data.map! {|datum| Question.new(datum)}
        data.first
    end

    def self.find_by_author_id(author_id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, author_id)
            SELECT * 
            FROM questions
            WHERE author_id = ?
        SQL
        data.map! {|datum| Question.new(datum)}
        
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end
    
    def author
        User.find_by_id(author_id)
    end

    def replies
        Reply.find_by_question_id(id)
    end

    def followers
        QuestionFollow.followers_for_question_id(id)
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
        data.map! {|datum| QuestionFollow.new(datum)}
        data.first
    end

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def self.followers_for_question_id(question_id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, question_id)
            SELECT
                users.id, users.fname, users.lname
            FROM users 
                JOIN question_follows ON users.id = question_follows.user_id
                JOIN questions ON question_follows.question_id = questions.id
            WHERE
                question_id = ?
        SQL
        data.map! {|datum| User.new(datum)}
    end

    def self.followed_for_user_id(user_id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, user_id)
            SELECT
                questions.id, questions.title, questions.body, questions.author_id
            FROM users 
                JOIN question_follows ON users.id = question_follows.user_id
                JOIN questions ON question_follows.question_id = questions.id
            WHERE
                user_id = ?
        SQL
        data.map! {|datum| Question.new(datum)}
    end
end

class Reply
    attr_reader :id
    attr_accessor :parent_reply_id, :question_id, :author_id, :body
    def self.find_by_id(id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM replies
            WHERE id = ?
        SQL
        data.map! {|datum| Reply.new(datum)}
        data.first
    end

    def self.find_by_author_id(author_id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, author_id)
            SELECT * 
            FROM replies
            WHERE author_id = ?
        SQL
        data.map! {|datum| Reply.new(datum)}
    end

    def self.find_by_question_id(question_id)
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, question_id)
            SELECT * 
            FROM replies
            WHERE question_id = ?
        SQL
        data.map! {|datum| Reply.new(datum)}
        data.first
    end

    def initialize(options)
        @id = options['id']
        @parent_reply_id = options['parent_reply_id']
        @question_id = options['question_id']
        @author_id = options['author_id']
        @body = options['body']
    end

    def author
        User.find_by_id(author_id)
    end
    def question
        Question.find_by_question_id(question_id)
    end

    def parent_reply_id
        Reply.find_by_id(parent_reply_id)
    end

    def child_replies
        data = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM replies
            WHERE parent_reply_id = ?
        SQL
        data.map! {|datum| Reply.new(datum)}
    end
end