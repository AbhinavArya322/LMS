package com.library.beans;

import com.library.utils.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookBean {
    private int bookId;
    private String title;
    private String author;
    private String isbn;
    private String publisher;
    private String category;
    private int publicationYear;
    private int totalCopies;
    private int availableCopies;
    private double price;
    private Timestamp dateAdded;
    private boolean isActive;
    
    // Constructors
    public BookBean() {}
    
    public BookBean(String title, String author, String isbn, String publisher, 
                   String category, int publicationYear, int totalCopies, double price) {
        this.title = title;
        this.author = author;
        this.isbn = isbn;
        this.publisher = publisher;
        this.category = category;
        this.publicationYear = publicationYear;
        this.totalCopies = totalCopies;
        this.availableCopies = totalCopies;
        this.price = price;
    }
    
    // Getters and Setters
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    
    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }
    
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public int getPublicationYear() { return publicationYear; }
    public void setPublicationYear(int publicationYear) { this.publicationYear = publicationYear; }
    
    public int getTotalCopies() { return totalCopies; }
    public void setTotalCopies(int totalCopies) { this.totalCopies = totalCopies; }
    
    public int getAvailableCopies() { return availableCopies; }
    public void setAvailableCopies(int availableCopies) { this.availableCopies = availableCopies; }
    
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    
    public Timestamp getDateAdded() { return dateAdded; }
    public void setDateAdded(Timestamp dateAdded) { this.dateAdded = dateAdded; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    
    // Add book to database
    public boolean addBook() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO books (title, author, isbn, publisher, category, publication_year, total_copies, available_copies, price) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, author);
            pstmt.setString(3, isbn);
            pstmt.setString(4, publisher);
            pstmt.setString(5, category);
            pstmt.setInt(6, publicationYear);
            pstmt.setInt(7, totalCopies);
            pstmt.setInt(8, availableCopies);
            pstmt.setDouble(9, price);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DatabaseConnection.closePreparedStatement(pstmt);
            DatabaseConnection.closeConnection(conn);
        }
    }
    
    // Get all books
    public static List<BookBean> getAllBooks() {
        List<BookBean> books = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM books WHERE is_active = TRUE ORDER BY title");
            
            while (rs.next()) {
                BookBean book = new BookBean();
                book.setBookId(rs.getInt("book_id"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setIsbn(rs.getString("isbn"));
                book.setPublisher(rs.getString("publisher"));
                book.setCategory(rs.getString("category"));
                book.setPublicationYear(rs.getInt("publication_year"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setPrice(rs.getDouble("price"));
                book.setDateAdded(rs.getTimestamp("date_added"));
                book.setActive(rs.getBoolean("is_active"));
                books.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closeStatement(stmt);
            DatabaseConnection.closeConnection(conn);
        }
        return books;
    }
    
    // Get book by ID
    public static BookBean getBookById(int bookId) {
        BookBean book = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            pstmt = conn.prepareStatement("SELECT * FROM books WHERE book_id = ? AND is_active = TRUE");
            pstmt.setInt(1, bookId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                book = new BookBean();
                book.setBookId(rs.getInt("book_id"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setIsbn(rs.getString("isbn"));
                book.setPublisher(rs.getString("publisher"));
                book.setCategory(rs.getString("category"));
                book.setPublicationYear(rs.getInt("publication_year"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setPrice(rs.getDouble("price"));
                book.setDateAdded(rs.getTimestamp("date_added"));
                book.setActive(rs.getBoolean("is_active"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closePreparedStatement(pstmt);
            DatabaseConnection.closeConnection(conn);
        }
        return book;
    }
    
    // Update book
    public boolean updateBook() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE books SET title = ?, author = ?, isbn = ?, publisher = ?, category = ?, publication_year = ?, total_copies = ?, available_copies = ?, price = ? WHERE book_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, author);
            pstmt.setString(3, isbn);
            pstmt.setString(4, publisher);
            pstmt.setString(5, category);
            pstmt.setInt(6, publicationYear);
            pstmt.setInt(7, totalCopies);
            pstmt.setInt(8, availableCopies);
            pstmt.setDouble(9, price);
            pstmt.setInt(10, bookId);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DatabaseConnection.closePreparedStatement(pstmt);
            DatabaseConnection.closeConnection(conn);
        }
    }
    
    // Search books
    public static List<BookBean> searchBooks(String searchTerm) {
        List<BookBean> books = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM books WHERE (title LIKE ? OR author LIKE ? OR isbn LIKE ? OR category LIKE ?) AND is_active = TRUE ORDER BY title";
            pstmt = conn.prepareStatement(sql);
            String searchPattern = "%" + searchTerm + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            pstmt.setString(4, searchPattern);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                BookBean book = new BookBean();
                book.setBookId(rs.getInt("book_id"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setIsbn(rs.getString("isbn"));
                book.setPublisher(rs.getString("publisher"));
                book.setCategory(rs.getString("category"));
                book.setPublicationYear(rs.getInt("publication_year"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setPrice(rs.getDouble("price"));
                book.setDateAdded(rs.getTimestamp("date_added"));
                book.setActive(rs.getBoolean("is_active"));
                books.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closePreparedStatement(pstmt);
            DatabaseConnection.closeConnection(conn);
        }
        return books;
    }
    
    // Get available books for issuing
    public static List<BookBean> getAvailableBooks() {
        List<BookBean> books = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM books WHERE is_active = TRUE AND available_copies > 0 ORDER BY title");
            
            while (rs.next()) {
                BookBean book = new BookBean();
                book.setBookId(rs.getInt("book_id"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setIsbn(rs.getString("isbn"));
                book.setPublisher(rs.getString("publisher"));
                book.setCategory(rs.getString("category"));
                book.setPublicationYear(rs.getInt("publication_year"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setPrice(rs.getDouble("price"));
                book.setDateAdded(rs.getTimestamp("date_added"));
                book.setActive(rs.getBoolean("is_active"));
                books.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closeStatement(stmt);
            DatabaseConnection.closeConnection(conn);
        }
        return books;
    }
    
}