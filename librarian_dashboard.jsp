<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.library.utils.DatabaseConnection" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Librarian Dashboard - Library Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Arial', sans-serif;
        }
        
        .main-header {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 30px 20px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            border: none;
            transition: transform 0.2s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #28a745;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 0.9rem;
            font-weight: 500;
            text-transform: uppercase;
        }
        
        .action-btn {
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            padding: 25px 15px;
            text-align: center;
            text-decoration: none;
            color: #495057;
            display: block;
            margin-bottom: 15px;
            transition: all 0.2s ease;
        }
        
        .action-btn:hover {
            border-color: #28a745;
            color: #28a745;
            text-decoration: none;
            transform: translateY(-2px);
        }
        
        .action-icon {
            font-size: 2rem;
            margin-bottom: 10px;
            display: block;
        }
        
        .action-title {
            font-weight: bold;
            font-size: 1.1rem;
            margin-bottom: 5px;
        }
        
        .action-desc {
            font-size: 0.85rem;
            color: #6c757d;
        }
        
        .activity-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        
        .activity-item {
            padding: 12px;
            border-left: 3px solid #28a745;
            background: #f8fff9;
            margin-bottom: 10px;
            border-radius: 0 5px 5px 0;
        }
        
        .navbar {
            background: linear-gradient(135deg, #28a745, #20c997) !important;
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <%
    String librarianRole = (String) session.getAttribute("role");
    String librarianName = (String) session.getAttribute("name");
    if (!"librarian".equals(librarianRole) && !"admin".equals(librarianRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get current date
    SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM dd, yyyy");
    String currentDate = sdf.format(new Date());
    
    // Get statistics
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    int totalBooks = 0, totalMembers = 0, issuedBooks = 0, overdueBooks = 0;
    int availableBooks = 0, newMembersThisMonth = 0;
    
    try {
        conn = DatabaseConnection.getConnection();
        stmt = conn.createStatement();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM books WHERE is_active = TRUE");
        if (rs.next()) totalBooks = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT SUM(available_copies) FROM books WHERE is_active = TRUE");
        if (rs.next()) availableBooks = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'member' AND is_active = TRUE");
        if (rs.next()) totalMembers = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM transactions WHERE status = 'issued'");
        if (rs.next()) issuedBooks = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM transactions WHERE status = 'issued' AND due_date < CURDATE()");
        if (rs.next()) overdueBooks = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'member' AND registration_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)");
        if (rs.next()) newMembersThisMonth = rs.getInt(1);
        rs.close();
        
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        DatabaseConnection.closeResultSet(rs);
        DatabaseConnection.closeStatement(stmt);
        DatabaseConnection.closeConnection(conn);
    }
    %>
    
    <!-- Header Section -->
    <div class="main-header">
        <div class="container">
            <div class="text-center">
                <h1><i class="fas fa-user-tie"></i> Librarian Dashboard</h1>
                <p class="mb-0">Welcome back, <%= librarianName %>! | <%= currentDate %></p>
            </div>
        </div>
    </div>
    
    <div class="container">
        <!-- Statistics Row -->
        <div class="row mb-4">
            <div class="col-md-2">
                <div class="stat-card">
                    <div class="stat-number"><%= totalBooks %></div>
                    <div class="stat-label">Total Books</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card">
                    <div class="stat-number"><%= availableBooks %></div>
                    <div class="stat-label">Available</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card">
                    <div class="stat-number"><%= totalMembers %></div>
                    <div class="stat-label">Members</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card">
                    <div class="stat-number"><%= issuedBooks %></div>
                    <div class="stat-label">Issued</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card">
                    <div class="stat-number text-danger"><%= overdueBooks %></div>
                    <div class="stat-label">Overdue</div>
                </div>
            </div>
            <div class="col-md-2">
                <div class="stat-card">
                    <div class="stat-number text-primary"><%= newMembersThisMonth %></div>
                    <div class="stat-label">New Members</div>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <h4 class="mb-3">Quick Actions</h4>
        <div class="row">
            <div class="col-lg-3 col-md-6">
                <a href="issue_book.jsp" class="action-btn">
                    <i class="fas fa-hand-point-right action-icon"></i>
                    <div class="action-title">Issue Books</div>
                    <div class="action-desc">Issue books to members</div>
                </a>
            </div>
            <div class="col-lg-3 col-md-6">
                <a href="return_book.jsp" class="action-btn">
                    <i class="fas fa-undo action-icon"></i>
                    <div class="action-title">Return Books</div>
                    <div class="action-desc">Process book returns</div>
                </a>
            </div>
            <div class="col-lg-3 col-md-6">
                <a href="add_book.jsp" class="action-btn">
                    <i class="fas fa-plus-circle action-icon"></i>
                    <div class="action-title">Add Books</div>
                    <div class="action-desc">Add new books</div>
                </a>
            </div>
            <div class="col-lg-3 col-md-6">
                <a href="add_member.jsp" class="action-btn">
                    <i class="fas fa-user-plus action-icon"></i>
                    <div class="action-title">Add Members</div>
                    <div class="action-desc">Register new members</div>
                </a>
            </div>
        </div>
        
        <div class="row">
            <div class="col-lg-3 col-md-6">
                <a href="search_books.jsp" class="action-btn">
                    <i class="fas fa-search action-icon"></i>
                    <div class="action-title">Search Books</div>
                    <div class="action-desc">Find books</div>
                </a>
            </div>
            <div class="col-lg-3 col-md-6">
                <a href="reports.jsp" class="action-btn">
                    <i class="fas fa-chart-bar action-icon"></i>
                    <div class="action-title">View Reports</div>
                    <div class="action-desc">Analytics & statistics</div>
                </a>
            </div>
            <div class="col-lg-3 col-md-6">
                <a href="manage_books.jsp" class="action-btn">
                    <i class="fas fa-cogs action-icon"></i>
                    <div class="action-title">Manage Books</div>
                    <div class="action-desc">Edit book details</div>
                </a>
            </div>
            <div class="col-lg-3 col-md-6">
                <a href="manage_members.jsp" class="action-btn">
                    <i class="fas fa-users-cog action-icon"></i>
                    <div class="action-title">Manage Members</div>
                    <div class="action-desc">Member administration</div>
                </a>
            </div>
        </div>
        
        <!-- Recent Activity -->
        <div class="activity-card">
            <h5><i class="fas fa-clock"></i> Recent Activity</h5>
            <div class="activity-item">
                <strong>System Status:</strong> Library management system is running smoothly
            </div>
            <div class="activity-item">
                <strong>Database:</strong> All connections working properly
            </div>
            <div class="activity-item">
                <strong>Summary:</strong> <%= issuedBooks %> books issued, <%= overdueBooks %> overdue
            </div>
            <% if (overdueBooks > 0) { %>
            <div class="activity-item" style="border-left-color: #dc3545; background: #fff5f5;">
                <strong>⚠️ Attention:</strong> <%= overdueBooks %> books are overdue
            </div>
            <% } %>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
