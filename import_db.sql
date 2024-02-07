PRAGMA foreign_keys = ON;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE if exists question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  subject_question_id INTEGER NOT NULL,
  parent_reply_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (subject_question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id) 
);

DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);




INSERT INTO
  users (fname, lname)
VALUES
  ('Arthur', 'Miller'),
  ('Eugene', 'O''Neill');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Question 1', 'I have a question', (SELECT id FROM users WHERE fname = 'Arthur' AND lname = 'Miller')),
  ('Question 2', 'What is SQL?', (SELECT id FROM users WHERE fname = 'Eugene' AND lname = 'O''Neill'));
