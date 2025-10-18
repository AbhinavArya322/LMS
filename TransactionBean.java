package com.library.beans;

import com.library.utils.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

public class TransactionBean {
    private int transactionId;
    private int bookId;
    private int userId;
    private int createdBy;
    private Date issueDate;
    private Date dueDate;
    private Date returnDate;
    private double fine;
    private String status;
    private Timestamp createdAt;
    
    // Additional fields for display purposes
    private String bookTitle;
    private String memberName;
    private String bookAuthor;
    private String memberEmail;
    private String memberPhone;
    
    // Constructors
    public TransactionBean() {}
    
    public TransactionBean(int bookId, int userId, int createdBy) {
        this.bookId = bookId;
        this.userId = userId;
        this.createdBy = createdBy;
        this.issueDate = Date.valueOf(LocalDate.now());
        this.dueDate = Date.valueOf(LocalDate.now().plusDays(14)); // 14 days loan period
        this.status = "issued";
        this.fine = 0.0;
    }
    
    // Getters and Setters
    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }
    
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    
    public Date getIssueDate() { return issueDate; }
    public void setIssueDate(Date issueDate) { this.issueDate = issueDate; }
    
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    
    public Date getReturnDate() { return returnDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }
    
    public double getFine() { return fine; }
    public void setFine(double fine) { this.fine = fine; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    // Display fields
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    
    public String getMemberName() { return memberName; }
    public void setMemberName(String memberName) { this.memberName = memberName; }
    
    public String getBookAuthor() { return bookAuthor; }
    public void setBookAuthor(String bookAuthor) { this.bookAuthor = bookAuthor; }
    
    public String getMemberEmail() { return memberEmail; }
    public void setMemberEmail(String memberEmail) { this.memberEmail = memberEmail; }
    
    public String getMemberPhone() { return memberPhone; }
    public void setMemberPhone(String memberPhone) { this.memberPhone = memberPhone; }
    
    // Issue book
    public boolean issueBook() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // Check if book is available
            pstmt = conn.prepareStatement("SELECT available_copies FROM books WHERE book_id = ? AND is_active = TRUE");
            pstmt.setInt(1, bookId);
            ResultSet rs = pstmt.executeQuery();
            
            if (!rs.next() || rs.getInt("available_copies") <= 0) {
                conn.rollback();
                return false; // Book not available
            }
            rs.close();
            pstmt.close();
            
            // Check user's current book count
            pstmt = conn.prepareStatement("SELECT COUNT(*) as count FROM transactions WHERE user_id = ? AND status = 'issued'");
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            int currentBooks = 0;
            if (rs.next()) {
                currentBooks = rs.getInt("count");
            }
            rs.close();
            pstmt.close();
            
            if (currentBooks >= 3) { // Maximum 3 books per user
                conn.rollback();
                return false;
            }
            
            // Issue the book
            pstmt = conn.prepareStatement("INSERT INTO transactions (book_id, user_id, issue_date, due_date, created_by) VALUES (?, ?, ?, ?, ?)");
            pstmt.setInt(1, bookId);
            pstmt.setInt(2, userId);
            pstmt.setDate(3, issueDate);
            pstmt.setDate(4, dueDate);
            pstmt.setInt(5, createdBy);
            
            int result = pstmt.executeUpdate();
            pstmt.close();
            
            if (result > 0) {
                // Update available copies
                pstmt = conn.prepareStatement("UPDATE books SET available_copies = available_copies - 1 WHERE book_id = ?");
                pstmt.setInt(1, bookId);
                pstmt.executeUpdate();
                
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {}
            DatabaseConnection.closePreparedStatement(pstmt);
            DatabaseConnection.closeConnection(conn);
        }
    }
    
    // Return book
    public static boolean returnBook(int transactionId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get transaction details
            pstmt = conn.prepareStatement("SELECT book_id, due_date FROM transactions WHERE transaction_id = ? AND status = 'issued'");
            pstmt.setInt(1, transactionId);
            ResultSet rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                return false; // Transaction not found or already returned
            }
            
            int bookId = rs.getInt("book_id");
            Date dueDate = rs.getDate("due_date");
            rs.close();
            pstmt.close();
            
            // Calculate fine if overdue
            Date today = Date.valueOf(LocalDate.now());
            double fine = 0.0;
            
            if (today.after(dueDate)) {
                long daysDiff = (today.getTime() - dueDate.getTime()) / (24 * 60 * 60 * 1000);
                fine = daysDiff * 1.0; // ₹1 per day fine
            }
            
            // Update transaction
            pstmt = conn.prepareStatement("UPDATE transactions SET return_date = ?, fine = ?, status = 'returned' WHERE transaction_id = ?");
            pstmt.setDate(1, today);
            pstmt.setDouble(2, fine);
            pstmt.setInt(3, transactionId);
            
            int result = pstmt.executeUpdate();
            pstmt.close();
            
            if (result > 0) {
                // Update available copies
                pstmt = conn.prepareStatement("UPDATE books SET available_copies = available_copies + 1 WHERE book_id = ?");
                pstmt.setInt(1, bookId);
                pstmt.executeUpdate();
                
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {}
            DatabaseConnection.closePreparedStatement(pstmt);
            DatabaseConnection.closeConnection(conn);
        }
    }
    
    // Get all issued books
    public static List<TransactionBean> getIssuedBooks() {
        List<TransactionBean> transactions = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            String sql = "SELECT t.transaction_id, t.book_id, t.user_id, t.issue_date, t.due_date, t.fine, t.status, " +
                        "b.title as book_title, b.author as book_author, " +
                        "u.name as member_name, u.email as member_email, u.phone as member_phone " +
                        "FROM transactions t " +
                        "JOIN books b ON t.book_id = b.book_id " +
                        "JOIN users u ON t.user_id = u.user_id " +
                        "WHERE t.status = 'issued' " +
                        "ORDER BY t.issue_date DESC";
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                TransactionBean transaction = new TransactionBean();
                transaction.setTransactionId(rs.getInt("transaction_id"));
                transaction.setBookId(rs.getInt("book_id"));
                transaction.setUserId(rs.getInt("user_id"));
                transaction.setIssueDate(rs.getDate("issue_date"));
                transaction.setDueDate(rs.getDate("due_date"));
                transaction.setFine(rs.getDouble("fine"));
                transaction.setStatus(rs.getString("status"));
                transaction.setBookTitle(rs.getString("book_title"));
                transaction.setBookAuthor(rs.getString("book_author"));
                transaction.setMemberName(rs.getString("member_name"));
                transaction.setMemberEmail(rs.getString("member_email"));
                transaction.setMemberPhone(rs.getString("member_phone"));
                transactions.add(transaction);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closeStatement(stmt);
            DatabaseConnection.closeConnection(conn);
        }
        return transactions;
    }
    
    // Get overdue books
    public static List<TransactionBean> getOverdueBooks() {
        List<TransactionBean> transactions = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            String sql = "SELECT t.transaction_id, t.book_id, t.user_id, t.issue_date, t.due_date, " +
                        "DATEDIFF(CURDATE(), t.due_date) as days_overdue, " +
                        "DATEDIFF(CURDATE(), t.due_date) * 1.0 as calculated_fine, " +
                        "b.title as book_title, b.author as book_author, " +
                        "u.name as member_name, u.email as member_email, u.phone as member_phone " +
                        "FROM transactions t " +
                        "JOIN books b ON t.book_id = b.book_id " +
                        "JOIN users u ON t.user_id = u.user_id " +
                        "WHERE t.status = 'issued' AND t.due_date < CURDATE() " +
                        "ORDER BY t.due_date ASC";
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                TransactionBean transaction = new TransactionBean();
                transaction.setTransactionId(rs.getInt("transaction_id"));
                transaction.setBookId(rs.getInt("book_id"));
                transaction.setUserId(rs.getInt("user_id"));
                transaction.setIssueDate(rs.getDate("issue_date"));
                transaction.setDueDate(rs.getDate("due_date"));
                transaction.setFine(rs.getDouble("calculated_fine"));
                transaction.setStatus("overdue");
                transaction.setBookTitle(rs.getString("book_title"));
                transaction.setBookAuthor(rs.getString("book_author"));
                transaction.setMemberName(rs.getString("member_name"));
                transaction.setMemberEmail(rs.getString("member_email"));
                transaction.setMemberPhone(rs.getString("member_phone"));
                transactions.add(transaction);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closeStatement(stmt);
            DatabaseConnection.closeConnection(conn);
        }
        return transactions;
    }
    
    // Get member's transaction history
    public static List<TransactionBean> getMemberTransactions(int userId) {
        List<TransactionBean> transactions = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT t.transaction_id, t.book_id, t.issue_date, t.due_date, t.return_date, t.fine, t.status, " +
                        "b.title as book_title, b.author as book_author " +
                        "FROM transactions t " +
                        "JOIN books b ON t.book_id = b.book_id " +
                        "WHERE t.user_id = ? " +
                        "ORDER BY t.created_at DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                TransactionBean transaction = new TransactionBean();
                transaction.setTransactionId(rs.getInt("transaction_id"));
                transaction.setBookId(rs.getInt("book_id"));
                transaction.setIssueDate(rs.getDate("issue_date"));
                transaction.setDueDate(rs.getDate("due_date"));
                transaction.setReturnDate(rs.getDate("return_date"));
                transaction.setFine(rs.getDouble("fine"));
                transaction.setStatus(rs.getString("status"));
                transaction.setBookTitle(rs.getString("book_title"));
                transaction.setBookAuthor(rs.getString("book_author"));
                transactions.add(transaction);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closePreparedStatement(pstmt);
            DatabaseConnection.closeConnection(conn);
        }
        return transactions;
    }
}