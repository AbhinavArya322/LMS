<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.library.utils.DatabaseConnection" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Library Reports - Library Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .form-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 30px;
        }
        .form-header {
            background: linear-gradient(135deg, #2E8B57, #20B2AA);
            color: white;
            padding: 20px;
            border-radius: 15px 15px 0 0;
            margin: -30px -30px 30px -30px;
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
        }
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
        }
        .report-section {
            margin-bottom: 30px;
        }
        .table-print {
            font-size: 12px;
        }
        @media print {
            .no-print { display: none; }
            body { background: white; }
            .form-card { box-shadow: none; border: 1px solid #ddd; }
            .form-header { background: #333 !important; }
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <div class="container mt-4">
        <%
        // Get comprehensive statistics
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        int totalBooks = 0, totalMembers = 0, totalTransactions = 0, activeIssued = 0;
        int overdueBooks = 0, booksAdded30Days = 0, membersAdded30Days = 0;
        double totalFines = 0.0, finesCollected = 0.0;
        
        try {
            conn = DatabaseConnection.getConnection();
            stmt = conn.createStatement();
            
            // Basic statistics
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM books WHERE is_active = TRUE");
            if (rs.next()) totalBooks = rs.getInt("count");
            rs.close();
            
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users WHERE role = 'member' AND is_active = TRUE");
            if (rs.next()) totalMembers = rs.getInt("count");
            rs.close();
            
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM transactions");
            if (rs.next()) totalTransactions = rs.getInt("count");
            rs.close();
            
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM transactions WHERE status = 'issued'");
            if (rs.next()) activeIssued = rs.getInt("count");
            rs.close();
            
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM transactions WHERE status = 'issued' AND due_date < CURDATE()");
            if (rs.next()) overdueBooks = rs.getInt("count");
            rs.close();
            
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM books WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)");
            if (rs.next()) booksAdded30Days = rs.getInt("count");
            rs.close();
            
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users WHERE role = 'member' AND registration_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)");
            if (rs.next()) membersAdded30Days = rs.getInt("count");
            rs.close();
            
            rs = stmt.executeQuery("SELECT SUM(fine) as total FROM transactions WHERE fine > 0");
            if (rs.next()) totalFines = rs.getDouble("total");
            rs.close();
            
            rs = stmt.executeQuery("SELECT SUM(fine) as total FROM transactions WHERE status = 'returned' AND fine > 0");
            if (rs.next()) finesCollected = rs.getDouble("total");
            rs.close();
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DatabaseConnection.closeResultSet(rs);
            DatabaseConnection.closeStatement(stmt);
            DatabaseConnection.closeConnection(conn);
        }
        %>
        
        <div class="row no-print mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2><i class="fas fa-chart-bar"></i> Library Management Reports</h2>
                    <button class="btn btn-primary" onclick="window.print()">
                        <i class="fas fa-print"></i> Print Report
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Executive Summary -->
        <div class="row report-section">
            <div class="col-12">
                <div class="form-card">
                    <div class="form-header">
                        <h4><i class="fas fa-chart-line"></i> Executive Summary</h4>
                        <small>Generated on <%= new java.text.SimpleDateFormat("MMMM dd, yyyy 'at' HH:mm").format(new java.util.Date()) %></small>
                    </div>
                    
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="stat-card">
                                <div class="stat-number"><%= totalBooks %></div>
                                <div>Total Books</div>
                                <small>+<%= booksAdded30Days %> this month</small>
                            </div>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="stat-card">
                                <div class="stat-number"><%= totalMembers %></div>
                                <div>Total Members</div>
                                <small>+<%= membersAdded30Days %> this month</small>
                            </div>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="stat-card">
                                <div class="stat-number"><%= totalTransactions %></div>
                                <div>Total Transactions</div>
                                <small>All time</small>
                            </div>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="stat-card">
                                <div class="stat-number"><%= activeIssued %></div>
                                <div>Currently Issued</div>
                                <small><%= overdueBooks %> overdue</small>
                            </div>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="stat-card">
                                <div class="stat-number">₹<%= String.format("%.0f", finesCollected) %></div>
                                <div>Fines Collected</div>
                                <small>₹<%= String.format("%.0f", totalFines - finesCollected) %> pending</small>
                            </div>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="stat-card">
                                <div class="stat-number"><%= totalBooks > 0 ? Math.round((double)activeIssued / totalBooks * 100) : 0 %>%</div>
                                <div>Utilization Rate</div>
                                <small>Books in circulation</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Popular Books Report -->
        <div class="row report-section">
            <div class="col-md-6">
                <div class="form-card">
                    <div class="form-header">
                        <h5><i class="fas fa-star"></i> Most Popular Books</h5>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-sm table-print">
                            <thead>
                                <tr>
                                    <th>Rank</th>
                                    <th>Book Title</th>
                                    <th>Author</th>
                                    <th>Times Borrowed</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                int rank = 1;
                                try {
                                    conn = DatabaseConnection.getConnection();
                                    String sql = "SELECT b.title, b.author, COUNT(t.transaction_id) as borrow_count " +
                                               "FROM books b " +
                                               "LEFT JOIN transactions t ON b.book_id = t.book_id " +
                                               "WHERE b.is_active = TRUE " +
                                               "GROUP BY b.book_id, b.title, b.author " +
                                               "ORDER BY borrow_count DESC LIMIT 10";
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                %>
                                <tr>
                                    <td><%= rank++ %></td>
                                    <td><%= rs.getString("title") %></td>
                                    <td><%= rs.getString("author") %></td>
                                    <td><span class="badge bg-info"><%= rs.getInt("borrow_count") %></span></td>
                                </tr>
                                <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    DatabaseConnection.closeResultSet(rs);
                                    DatabaseConnection.closeStatement(stmt);
                                    DatabaseConnection.closeConnection(conn);
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-card">
                    <div class="form-header">
                        <h5><i class="fas fa-users"></i> Most Active Members</h5>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-sm table-print">
                            <thead>
                                <tr>
                                    <th>Rank</th>
                                    <th>Member Name</th>
                                    <th>Books Borrowed</th>
                                    <th>Total Fine</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                rank = 1;
                                try {
                                    conn = DatabaseConnection.getConnection();
                                    String sql = "SELECT u.name, COUNT(t.transaction_id) as borrow_count, " +
                                               "COALESCE(SUM(t.fine), 0) as total_fine " +
                                               "FROM users u " +
                                               "LEFT JOIN transactions t ON u.user_id = t.user_id " +
                                               "WHERE u.role = 'member' AND u.is_active = TRUE " +
                                               "GROUP BY u.user_id, u.name " +
                                               "ORDER BY borrow_count DESC LIMIT 10";
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                %>
                                <tr>
                                    <td><%= rank++ %></td>
                                    <td><%= rs.getString("name") %></td>
                                    <td><span class="badge bg-success"><%= rs.getInt("borrow_count") %></span></td>
                                    <td>₹<%= String.format("%.2f", rs.getDouble("total_fine")) %></td>
                                </tr>
                                <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    DatabaseConnection.closeResultSet(rs);
                                    DatabaseConnection.closeStatement(stmt);
                                    DatabaseConnection.closeConnection(conn);
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Category-wise Distribution -->
        <div class="row report-section">
            <div class="col-12">
                <div class="form-card">
                    <div class="form-header">
                        <h5><i class="fas fa-chart-pie"></i> Category-wise Book Distribution</h5>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Category</th>
                                    <th>Total Books</th>
                                    <th>Total Copies</th>
                                    <th>Available Copies</th>
                                    <th>Utilization %</th>
                                    <th>Times Borrowed</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    conn = DatabaseConnection.getConnection();
                                    String sql = "SELECT b.category, " +
                                               "COUNT(DISTINCT b.book_id) as book_count, " +
                                               "SUM(b.total_copies) as total_copies, " +
                                               "SUM(b.available_copies) as available_copies, " +
                                               "COUNT(t.transaction_id) as borrow_count " +
                                               "FROM books b " +
                                               "LEFT JOIN transactions t ON b.book_id = t.book_id " +
                                               "WHERE b.is_active = TRUE " +
                                               "GROUP BY b.category " +
                                               "ORDER BY book_count DESC";
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                        int totalCopies = rs.getInt("total_copies");
                                        int availableCopies = rs.getInt("available_copies");
                                        int utilization = totalCopies > 0 ? Math.round((float)(totalCopies - availableCopies) / totalCopies * 100) : 0;
                                %>
                                <tr>
                                    <td><strong><%= rs.getString("category") %></strong></td>
                                    <td><%= rs.getInt("book_count") %></td>
                                    <td><%= totalCopies %></td>
                                    <td><%= availableCopies %></td>
                                    <td>
                                        <div class="progress" style="height: 20px;">
                                            <div class="progress-bar" style="width: <%= utilization %>%">
                                                <%= utilization %>%
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="badge bg-primary"><%= rs.getInt("borrow_count") %></span></td>
                                </tr>
                                <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    DatabaseConnection.closeResultSet(rs);
                                    DatabaseConnection.closeStatement(stmt);
                                    DatabaseConnection.closeConnection(conn);
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Overdue Books Report -->
        <div class="row report-section">
            <div class="col-12">
                <div class="form-card">
                    <div class="form-header">
                        <h5><i class="fas fa-exclamation-triangle text-warning"></i> Overdue Books Report</h5>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Book Title</th>
                                    <th>Member Name</th>
                                    <th>Issue Date</th>
                                    <th>Due Date</th>
                                    <th>Days Overdue</th>
                                    <th>Fine Amount</th>
                                    <th>Contact</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    conn = DatabaseConnection.getConnection();
                                    String sql = "SELECT b.title, u.name, u.email, u.phone, " +
                                               "t.issue_date, t.due_date, " +
                                               "DATEDIFF(CURDATE(), t.due_date) as days_overdue, " +
                                               "DATEDIFF(CURDATE(), t.due_date) * 1.0 as fine_amount " +
                                               "FROM transactions t " +
                                               "JOIN books b ON t.book_id = b.book_id " +
                                               "JOIN users u ON t.user_id = u.user_id " +
                                               "WHERE t.status = 'issued' AND t.due_date < CURDATE() " +
                                               "ORDER BY days_overdue DESC";
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                %>
                                <tr>
                                    <td><%= rs.getString("title") %></td>
                                    <td><%= rs.getString("name") %></td>
                                    <td><%= rs.getDate("issue_date") %></td>
                                    <td class="text-danger"><%= rs.getDate("due_date") %></td>
                                    <td><span class="badge bg-danger"><%= rs.getInt("days_overdue") %> days</span></td>
                                    <td class="text-danger"><strong>₹<%= String.format("%.2f", rs.getDouble("fine_amount")) %></strong></td>
                                    <td>
                                        <small>
                                            <%= rs.getString("email") %><br>
                                            <%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %>
                                        </small>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    DatabaseConnection.closeResultSet(rs);
                                    DatabaseConnection.closeStatement(stmt);
                                    DatabaseConnection.closeConnection(conn);
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Monthly Activity Report -->
        <div class="row report-section">
            <div class="col-12">
                <div class="form-card">
                    <div class="form-header">
                        <h5><i class="fas fa-calendar-alt"></i> Monthly Activity Summary</h5>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>Month</th>
                                    <th>Books Issued</th>
                                    <th>Books Returned</th>
                                    <th>New Members</th>
                                    <th>New Books Added</th>
                                    <th>Fines Collected</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    conn = DatabaseConnection.getConnection();
                                    String sql = "SELECT " +
                                               "DATE_FORMAT(created_at, '%Y-%m') as month, " +
                                               "COUNT(CASE WHEN status IN ('issued', 'returned') THEN 1 END) as books_issued, " +
                                               "COUNT(CASE WHEN status = 'returned' THEN 1 END) as books_returned, " +
                                               "0 as new_members, " +
                                               "0 as new_books, " +
                                               "SUM(CASE WHEN status = 'returned' THEN fine ELSE 0 END) as fines_collected " +
                                               "FROM transactions " +
                                               "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                                               "GROUP BY DATE_FORMAT(created_at, '%Y-%m') " +
                                               "ORDER BY month DESC " +
                                               "LIMIT 6";
                                    stmt = conn.createStatement();
                                    rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                %>
                                <tr>
                                    <td><%= rs.getString("month") %></td>
                                    <td><%= rs.getInt("books_issued") %></td>
                                    <td><%= rs.getInt("books_returned") %></td>
                                    <td>-</td>
                                    <td>-</td>
                                    <td>₹<%= String.format("%.2f", rs.getDouble("fines_collected")) %></td>
                                </tr>
                                <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    DatabaseConnection.closeResultSet(rs);
                                    DatabaseConnection.closeStatement(stmt);
                                    DatabaseConnection.closeConnection(conn);
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>