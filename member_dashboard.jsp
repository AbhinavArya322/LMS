<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.TransactionBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Member Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <%
    String memberName = (String) session.getAttribute("name");
    Integer memberId = (Integer) session.getAttribute("userId");
    if (memberId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    %>
    
    <div class="container mt-4">
        <h3 class="mb-4"><i class="fas fa-home"></i> Welcome, <%= memberName %></h3>
        
        <div class="card mb-4">
            <div class="card-header bg-success text-white">
                <h5><i class="fas fa-book-reader"></i> My Current Books</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Book Title</th>
                                <th>Issue Date</th>
                                <th>Due Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            List<TransactionBean> myBooks = TransactionBean.getMemberTransactions(memberId);
                            if (myBooks.isEmpty()) {
                            %>
                            <tr>
                                <td colspan="4" class="text-center text-muted">
                                    No books currently borrowed
                                </td>
                            </tr>
                            <%
                            } else {
                                for (TransactionBean transaction : myBooks) {
                                    if ("issued".equals(transaction.getStatus())) {
                                        java.util.Date today = new java.util.Date();
                                        boolean isOverdue = today.after(transaction.getDueDate());
                            %>
                            <tr>
                                <td><%= transaction.getBookTitle() %></td>
                                <td><%= transaction.getIssueDate() %></td>
                                <td><%= transaction.getDueDate() %></td>
                                <td>
                                    <% if (isOverdue) { %>
                                    <span class="badge bg-danger">Overdue</span>
                                    <% } else { %>
                                    <span class="badge bg-success">Active</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                    }
                                }
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body text-center">
                        <i class="fas fa-search fa-3x text-primary mb-3"></i>
                        <h5>Search Books</h5>
                        <p>Find and explore available books in the library</p>
                        <a href="search_books.jsp" class="btn btn-primary">
                            <i class="fas fa-search"></i> Search Now
                        </a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body text-center">
                        <i class="fas fa-history fa-3x text-info mb-3"></i>
                        <h5>Reading History</h5>
                        <p>View your complete borrowing history</p>
                        <a href="my_transactions.jsp" class="btn btn-info">
                            <i class="fas fa-history"></i> View History
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
