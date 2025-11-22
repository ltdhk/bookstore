USE bookstore_db;

-- Initial Users
INSERT INTO `users` (`username`, `password`, `nickname`, `avatar`, `coins`, `bonus`, `is_svip`) VALUES 
('admin', '123456', 'Admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Admin', 1000, 500, 1),
('user1', '123456', 'Reader One', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Reader1', 0, 0, 0);

-- Initial Books
INSERT INTO `books` (`title`, `author`, `cover_url`, `description`, `category`, `status`, `views`, `rating`) VALUES 
('Reborn: No More Second Chances', 'Ernest', 'https://via.placeholder.com/150', 'A story about rebirth and revenge.', 'Romance', 'Ongoing', 23000, 4.8),
('Pre-Wedding Getaway', 'Twain', 'https://via.placeholder.com/150', 'Fiance falls for the B&B owner.', 'Romance', 'Completed', 4321, 4.5),
('The Great Adventure', 'J.K. Rowling', 'https://via.placeholder.com/150', 'A magical journey.', 'Fantasy', 'Completed', 100000, 5.0);

-- Initial Chapters
INSERT INTO `chapters` (`book_id`, `title`, `content`, `order_num`) VALUES 
(1, 'Chapter 1: The Beginning', 'This is the content of chapter 1...', 1),
(1, 'Chapter 2: The Return', 'This is the content of chapter 2...', 2),
(2, 'Chapter 1: Arrival', 'Arriving at the B&B...', 1);

-- Initial Bookshelf
INSERT INTO `bookshelf` (`user_id`, `book_id`, `last_read_chapter_id`) VALUES 
(1, 1, 1);
