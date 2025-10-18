<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.library.utils.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <%
    String adminRole = (String) session.getAttribute("role");
    if (!"admin".equals(adminRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get statistics
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    int totalBooks = 0, totalMembers = 0, totalLibrarians = 0, currentlyIssued = 0, overdueBooks = 0;
    
    try {
        conn = DatabaseConnection.getConnection();
        stmt = conn.createStatement();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM books WHERE is_active = TRUE");
        if (rs.next()) totalBooks = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'member' AND is_active = TRUE");
        if (rs.next()) totalMembers = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'librarian' AND is_active = TRUE");
        if (rs.next()) totalLibrarians = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM transactions WHERE status = 'issued'");
        if (rs.next()) currentlyIssued = rs.getInt(1);
        rs.close();
        
        rs = stmt.executeQuery("SELECT COUNT(*) FROM transactions WHERE status = 'issued' AND due_date < CURDATE()");
        if (rs.next()) overdueBooks = rs.getInt(1);
        rs.close();
        
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        DatabaseConnection.closeResultSet(rs);
        DatabaseConnection.closeStatement(stmt);
        DatabaseConnection.closeConnection(conn);
    }
    %>
    
    <div class="container mt-4">
        <h3 class="mb-4"><i class="fas fa-tachometer-alt"></i> System Overview</h3>
        
        <!-- Statistics Cards -->
        <div class="row text-center mb-4">
            <div class="col-md-2 mb-3">
                <div class="card bg-primary text-white">
                    <div class="card-body">
                        <h4><%= totalBooks %></h4>
                        <small>Total Books</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2 mb-3">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <h4><%= totalMembers %></h4>
                        <small>Members</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2 mb-3">
                <div class="card bg-info text-white">
                    <div class="card-body">
                        <h4><%= totalLibrarians %></h4>
                        <small>Librarians</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2 mb-3">
                <div class="card bg-warning text-dark">
                    <div class="card-body">
                        <h4><%= currentlyIssued %></h4>
                        <small>Currently Issued</small>
                    </div>
                </div>
            </div>
            <div class="col-md-2 mb-3">
                <div class="card bg-danger text-white">
                    <div class="card-body">
                        <h4><%= overdueBooks %></h4>
                        <small>Overdue</small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="row">
            <div class="col-md-3 mb-3">
                <a href="librarian_dashboard.jsp" class="btn btn-outline-primary w-100 p-3">
                    <i class="fas fa-user-tie fa-2x mb-2"></i><br>
                    <strong>Librarian View</strong><br>
                    <small>Switch to librarian dashboard</small>
                </a>
            </div>
            <div class="col-md-3 mb-3">
                <a href="add_book.jsp" class="btn btn-outline-success w-100 p-3">
                    <i class="fas fa-plus-circle fa-2x mb-2"></i><br>
                    <strong>Add Books</strong><br>
                    <small>Add new books to inventory</small>
                </a>
            </div>
            <div class="col-md-3 mb-3">
                <a href="add_member.jsp" class="btn btn-outline-info w-100 p-3">
                    <i class="fas fa-user-plus fa-2x mb-2"></i><br>
                    <strong>Add Members</strong><br>
                    <small>Register new library members</small>
                </a>
            </div>
            <div class="col-md-3 mb-3">
                <a href="reports.jsp" class="btn btn-outline-warning w-100 p-3">
                    <i class="fas fa-chart-bar fa-2x mb-2"></i><br>
                    <strong>View Reports</strong><br>
                    <small>Analytics and statistics</small>
                </a>
            </div>
        </div>
        
        <div class="alert alert-info mt-4">
            <i class="fas fa-info-circle"></i>
            <strong>Admin Panel:</strong> You have full system access. Monitor overdue books and system health regularly.
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
