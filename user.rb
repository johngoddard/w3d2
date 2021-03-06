require_relative 'questionsdatabase'
require_relative 'modelbase'

class User < ModelBase
  # def self.find_by_id(id)
  #   user = QuestionsDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       users
  #     WHERE
  #       id = ?
  #   SQL
  #
  #   return nil unless user.length > 0
  #   User.new(user.first)
  # end



  def self.find_by_name(fname, lname)
    name = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    raise "#{fname} #{lname} does not exist" if name.empty?
    User.new(name.first)
  end

  attr_accessor :fname, :lname, :id

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    raise "#{self} doesn't exist" unless @id
    Question.find_by_author(@id)
  end

  def authored_replies
    raise "#{self} doesn't exist" unless @id
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    Follow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    Like.liked_questions_for_user_id(@id)
  end

  def average_karma
    avg_likes = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      CAST(count(question_likes.id) AS FLOAT) / count(DISTINCT questions.id) AS avg_karma
    FROM
      questions
    LEFT JOIN
      question_likes ON questions.id = question_likes.question_id
    WHERE
      questions.user_id = ?
    SQL
    avg_likes.first['avg_karma']
  end
end
