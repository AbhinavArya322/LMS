-- ===================================
-- LIBRARY MANAGEMENT SYSTEM DATABASE
-- Complete Database Setup Script
-- ===================================

-- Drop existing database and create fresh
DROP DATABASE IF EXISTS library_management_system;
CREATE DATABASE library_management_system;
USE library_management_system;

-- ===================================
-- TABLE CREATION
-- ===================================

-- Create Users table (Admin, Librarian, Member)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    address TEXT,
    role ENUM('admin', 'librarian', 'member') NOT NULL DEFAULT 'member',
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(13) UNIQUE,
    publisher VARCHAR(100),
    category VARCHAR(50),
    publication_year YEAR,
    total_copies INT NOT NULL DEFAULT 1 CHECK (total_copies >= 0),
    available_copies INT NOT NULL DEFAULT 1 CHECK (available_copies >= 0),
    price DECIMAL(10,2),
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_available_copies CHECK (available_copies <= total_copies)
);

-- Create Transactions table (Issue/Return tracking)
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    fine DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('issued', 'returned', 'overdue') DEFAULT 'issued',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- Create Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create System Settings table
CREATE TABLE system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_name VARCHAR(50) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Reservations table (Future enhancement)
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    reservation_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('pending', 'fulfilled', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ===================================
-- SYSTEM SETTINGS DATA
-- ===================================

INSERT INTO system_settings (setting_name, setting_value, description) VALUES
('fine_per_day', '1.00', 'Fine amount per day for overdue books'),
('max_books_per_user', '3', 'Maximum number of books a user can borrow'),
('loan_period_days', '14', 'Default loan period in days'),
('library_name', 'Central Library Management System', 'Name of the library'),
('library_address', '123 Education Street, Knowledge City', 'Library address'),
('library_phone', '+91-9876543210', 'Library contact phone'),
('library_email', 'info@centrallibrary.edu', 'Library contact email');

-- ===================================
-- CATEGORIES DATA
-- ===================================

INSERT INTO categories (category_name, description) VALUES
('Programming', 'Books related to programming languages and software development'),
('Computer Science', 'General computer science topics including algorithms and theory'),
('Database', 'Database design, management and administration'),
('AI/ML', 'Artificial Intelligence and Machine Learning'),
('Web Development', 'Frontend and backend web development technologies'),
('Mobile Development', 'Android and iOS mobile application development'),
('Data Science', 'Data analysis, statistics and data visualization'),
('Networking', 'Computer networks and network security'),
('Operating Systems', 'Operating systems concepts and administration'),
('Software Engineering', 'Software development methodologies and practices');

-- ===================================
-- DEFAULT USERS DATA
-- ===================================

-- Insert default users (Note: In production, passwords should be hashed)
INSERT INTO users (username, password, name, email, phone, role, registration_date) VALUES
('admin', 'admin123', 'System Administrator', 'admin@library.com', '9876543210', 'admin', '2024-01-01'),
('librarian1', 'lib123', 'John Librarian', 'librarian@library.com', '9876543211', 'librarian', '2024-01-02'),
('librarian2', 'lib456', 'Mary Librarian', 'mary.lib@library.com', '9876543220', 'librarian', '2024-01-03'),
('member1', 'mem123', 'Alice Johnson', 'alice@email.com', '9876543212', 'member', '2024-01-03'),
('member2', 'mem456', 'Bob Smith', 'bob@email.com', '9876543213', 'member', '2024-01-04'),
('member3', 'mem789', 'Charlie Brown', 'charlie@email.com', '9876543214', 'member', '2024-01-05'),
('member4', 'mem101', 'Diana Davis', 'diana@email.com', '9876543215', 'member', '2024-01-06'),
('member5', 'mem202', 'Eve Wilson', 'eve@email.com', '9876543216', 'member', '2024-01-07');

-- ===================================
-- SAMPLE BOOKS DATA
-- ===================================

INSERT INTO books (title, author, isbn, publisher, category, publication_year, total_copies, available_copies, price) VALUES
('Java: The Complete Reference', 'Herbert Schildt', '9781260463330', 'McGraw Hill', 'Programming', 2020, 5, 3, 599.00),
('Data Structures and Algorithms in Java', 'Robert Sedgewick', '9780321573513', 'Addison-Wesley', 'Computer Science', 2019, 3, 2, 750.00),
('Database System Concepts', 'Abraham Silberschatz', '9780078022159', 'McGraw Hill', 'Database', 2019, 4, 4, 850.00),
('Clean Code', 'Robert C. Martin', '9780132350884', 'Prentice Hall', 'Programming', 2018, 2, 1, 650.00),
('Introduction to Machine Learning', 'Alpaydin Ethem', '9780262028189', 'MIT Press', 'AI/ML', 2020, 3, 3, 900.00),
('Effective Java', 'Joshua Bloch', '9780134685991', 'Addison-Wesley', 'Programming', 2018, 4, 2, 720.00),
('Design Patterns', 'Gang of Four', '9780201633612', 'Addison-Wesley', 'Software Engineering', 1994, 3, 3, 580.00),
('Computer Networks', 'Andrew Tanenbaum', '9780132126953', 'Prentice Hall', 'Networking', 2019, 2, 2, 680.00),
('Operating System Concepts', 'Abraham Silberschatz', '9781118063330', 'John Wiley', 'Operating Systems', 2018, 3, 1, 790.00),
('Python for Data Science', 'Jake VanderPlas', '9781491912058', 'O''Reilly', 'Data Science', 2020, 4, 4, 620.00),
('React: The Complete Guide', 'Maximilian Schwarzmüller', '9781234567890', 'Tech Publications', 'Web Development', 2021, 3, 3, 540.00),
('Android Development', 'Mark Murphy', '9780987654321', 'CommonsWare', 'Mobile Development', 2020, 2, 2, 690.00),
('Spring Boot in Action', 'Craig Walls', '9781617292545', 'Manning', 'Web Development', 2019, 3, 3, 580.00),
('Artificial Intelligence: A Modern Approach', 'Stuart Russell', '9780134610993', 'Pearson', 'AI/ML', 2020, 2, 2, 950.00),
('System Design Interview', 'Alex Xu', '9781736049112', 'ByteByteGo', 'Software Engineering', 2021, 4, 4, 750.00);

-- ===================================
-- SAMPLE TRANSACTIONS DATA
-- ===================================

-- Insert sample transactions for testing
INSERT INTO transactions (book_id, user_id, issue_date, due_date, return_date, fine, status, created_by) VALUES
(1, 4, '2024-10-01', '2024-10-15', NULL, 0.00, 'issued', 2),
(2, 5, '2024-09-20', '2024-10-04', '2024-10-02', 0.00, 'returned', 2),
(4, 4, '2024-09-25', '2024-10-09', NULL, 8.00, 'overdue', 2),
(6, 6, '2024-09-30', '2024-10-14', NULL, 0.00, 'issued', 2),
(9, 7, '2024-09-15', '2024-09-29', '2024-09-28', 0.00, 'returned', 3),
(3, 8, '2024-10-03', '2024-10-17', NULL, 0.00, 'issued', 3),
(7, 5, '2024-09-28', '2024-10-12', NULL, 0.00, 'issued', 2),
(10, 6, '2024-09-18', '2024-10-02', '2024-09-30', 0.00, 'returned', 3),
(11, 7, '2024-10-05', '2024-10-19', NULL, 0.00, 'issued', 2),
(12, 8, '2024-09-22', '2024-10-06', NULL, 2.00, 'overdue', 3);

-- ===================================
-- INDEXES FOR PERFORMANCE
-- ===================================

CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_category ON books(category);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_book ON transactions(book_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_due_date ON transactions(due_date);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ===================================
-- TRIGGERS FOR BUSINESS LOGIC
-- ===================================

-- Trigger to update book status to overdue
DELIMITER $$
CREATE TRIGGER update_overdue_status
AFTER UPDATE ON transactions
FOR each ROW
BEGIN
    IF NEW.status = 'issued' AND NEW.due_date < CURDATE() THEN
        UPDATE transactions 
        SET status = 'overdue' 
        WHERE transaction_id = NEW.transaction_id;
    END IF;
END$$
DELIMITER ;

-- ===================================
-- VIEWS FOR REPORTING
-- ===================================

-- View for overdue books
CREATE VIEW overdue_books_view AS
SELECT 
    t.transaction_id,
    b.title AS book_title,
    b.author AS book_author,
    u.name AS member_name,
    u.email AS member_email,
    u.phone AS member_phone,
    t.issue_date,
    t.due_date,
    DATEDIFF(CURDATE(), t.due_date) AS days_overdue,
    DATEDIFF(CURDATE(), t.due_date) * 1.0 AS calculated_fine
FROM transactions t
JOIN books b ON t.book_id = b.book_id
JOIN users u ON t.user_id = u.user_id
WHERE t.status = 'issued' AND t.due_date < CURDATE();

-- View for library statistics
CREATE VIEW library_stats_view AS
SELECT 
    (SELECT COUNT(*) FROM books WHERE is_active = TRUE) AS total_books,
    (SELECT COUNT(*) FROM users WHERE role = 'member' AND is_active = TRUE) AS total_members,
    (SELECT COUNT(*) FROM transactions WHERE status = 'issued') AS currently_issued,
    (SELECT COUNT(*) FROM transactions WHERE status = 'issued' AND due_date < CURDATE()) AS overdue_books,
    (SELECT SUM(fine) FROM transactions WHERE status = 'returned' AND fine > 0) AS total_fines_collected;

-- ===================================
-- STORED PROCEDURES
-- ===================================

-- Procedure to issue a book
DELIMITER $$
CREATE PROCEDURE IssueBook(
    IN p_book_id INT,
    IN p_user_id INT,
    IN p_created_by INT,
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE book_available INT DEFAULT 0;
    DECLARE user_book_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error occurred during book issue';
    END;
    
    START TRANSACTION;
    
    -- Check book availability
    SELECT available_copies INTO book_available 
    FROM books 
    WHERE book_id = p_book_id AND is_active = TRUE;
    
    -- Check user's current book count
    SELECT COUNT(*) INTO user_book_count 
    FROM transactions 
    WHERE user_id = p_user_id AND status = 'issued';
    
    IF book_available <= 0 THEN
        SET p_result = 'Book not available';
        ROLLBACK;
    ELSEIF user_book_count >= 3 THEN
        SET p_result = 'User has reached maximum book limit';
        ROLLBACK;
    ELSE
        -- Issue the book
        INSERT INTO transactions (book_id, user_id, issue_date, due_date, created_by) 
        VALUES (p_book_id, p_user_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), p_created_by);
        
        -- Update available copies
        UPDATE books 
        SET available_copies = available_copies - 1 
        WHERE book_id = p_book_id;
        
        SET p_result = 'Book issued successfully';
        COMMIT;
    END IF;
END$$
DELIMITER ;

-- ===================================
-- VERIFICATION QUERIES
-- ===================================

-- Display success message and basic stats
SELECT 'Database setup completed successfully!' AS Status;

SELECT 
    'Total Books' AS Metric, COUNT(*) AS Count FROM books WHERE is_active = TRUE
UNION ALL
SELECT 
    'Total Members' AS Metric, COUNT(*) AS Count FROM users WHERE role = 'member'
UNION ALL
SELECT 
    'Total Transactions' AS Metric, COUNT(*) AS Count FROM transactions
UNION ALL
SELECT 
    'Currently Issued' AS Metric, COUNT(*) AS Count FROM transactions WHERE status = 'issued';

-- Show sample data
SELECT 'Sample Books:' AS Info;
SELECT title, author, category, total_copies, available_copies FROM books LIMIT 5;

SELECT 'Sample Users:' AS Info;
SELECT username, name, role FROM users LIMIT 5;

SELECT 'Sample Transactions:' AS Info;
SELECT t.transaction_id, b.title, u.name, t.issue_date, t.status 
FROM transactions t
JOIN books b ON t.book_id = b.book_id
JOIN users u ON t.user_id = u.user_id
LIMIT 5;