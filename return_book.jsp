<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.TransactionBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Return Books</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .overdue-row { background-color: #fff5f5; }
        .fine-amount { font-weight: bold; color: #dc3545; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <div class="container mt-4">
        <%
        String message = "";
        String messageType = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String transactionIdStr = request.getParameter("transactionId");
            
            if (transactionIdStr != null && !transactionIdStr.trim().isEmpty()) {
                try {
                    int transactionId = Integer.parseInt(transactionIdStr);
                    
                    if (TransactionBean.returnBook(transactionId)) {
                        message = "Book returned successfully! Fine (if any) has been calculated.";
                        messageType = "success";
                    } else {
                        message = "Failed to return book. The book may have already been returned or transaction ID is invalid.";
                        messageType = "danger";
                    }
                } catch (NumberFormatException e) {
                    message = "Invalid transaction ID format: " + transactionIdStr;
                    messageType = "danger";
                }
            } else {
                message = "Transaction ID is missing or empty.";
                messageType = "danger";
            }
        }
        %>
        
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-success text-white">
                        <h4><i class="fas fa-undo"></i> Return Books</h4>
                        <p class="mb-0">Process book returns and calculate fines</p>
                    </div>
                </div>
            </div>
        </div>
        
        <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= messageType %> alert-dismissible fade show">
            <i class="fas fa-<%= messageType.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5>Currently Issued Books</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Book Details</th>
                                        <th>Member</th>
                                        <th>Issue Date</th>
                                        <th>Due Date</th>
                                        <th>Days</th>
                                        <th>Fine</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    List<TransactionBean> issuedBooks = TransactionBean.getIssuedBooks();
                                    List<TransactionBean> overdueBooks = TransactionBean.getOverdueBooks();
                                    
                                    // Show overdue books first
                                    for (TransactionBean transaction : overdueBooks) {
                                        java.util.Date today = new java.util.Date();
                                        long daysDiff = (today.getTime() - transaction.getDueDate().getTime()) / (24 * 60 * 60 * 1000);
                                        double fine = daysDiff * 1.0; // ₹1 per day
                                    %>
                                    <tr class="overdue-row">
                                        <td>
                                            <strong class="text-danger"><%= transaction.getBookTitle() %></strong><br>
                                            <small class="text-muted">by <%= transaction.getBookAuthor() %></small>
                                        </td>
                                        <td>
                                            <strong><%= transaction.getMemberName() %></strong><br>
                                            <small class="text-muted"><%= transaction.getMemberEmail() %></small>
                                            <% if (transaction.getMemberPhone() != null) { %>
                                            <br><small class="text-muted">📞 <%= transaction.getMemberPhone() %></small>
                                            <% } %>
                                        </td>
                                        <td><%= transaction.getIssueDate() %></td>
                                        <td>
                                            <span class="text-danger fw-bold"><%= transaction.getDueDate() %></span><br>
                                            <span class="badge bg-danger">OVERDUE</span>
                                        </td>
                                        <td>
                                            <span class="text-danger fw-bold"><%= daysDiff %> days late</span>
                                        </td>
                                        <td>
                                            <span class="fine-amount">₹<%= String.format("%.2f", fine) %></span>
                                        </td>
                                        <td>
                                            <form method="post" action="return_book.jsp" style="display: inline;">
                                                <input type="hidden" name="transactionId" value="<%= transaction.getTransactionId() %>">
                                                <button type="submit" class="btn btn-success btn-sm" 
                                                        onclick="return confirm('Return this book?\\nFine: ₹<%= String.format("%.2f", fine) %>')">
                                                    <i class="fas fa-check"></i> Return
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                    <%
                                    }
                                    
                                    // Show regular issued books (not overdue)
                                    for (TransactionBean transaction : issuedBooks) {
                                        java.util.Date today = new java.util.Date();
                                        if (!today.after(transaction.getDueDate())) { // Only show non-overdue books
                                            long daysLeft = (transaction.getDueDate().getTime() - today.getTime()) / (24 * 60 * 60 * 1000);
                                    %>
                                    <tr>
                                        <td>
                                            <strong class="text-primary"><%= transaction.getBookTitle() %></strong><br>
                                            <small class="text-muted">by <%= transaction.getBookAuthor() %></small>
                                        </td>
                                        <td>
                                            <strong><%= transaction.getMemberName() %></strong><br>
                                            <small class="text-muted"><%= transaction.getMemberEmail() %></small>
                                            <% if (transaction.getMemberPhone() != null) { %>
                                            <br><small class="text-muted">📞 <%= transaction.getMemberPhone() %></small>
                                            <% } %>
                                        </td>
                                        <td><%= transaction.getIssueDate() %></td>
                                        <td>
                                            <%= transaction.getDueDate() %><br>
                                            <span class="badge bg-success">ON TIME</span>
                                        </td>
                                        <td>
                                            <span class="text-success"><%= daysLeft %> days left</span>
                                        </td>
                                        <td>
                                            <span class="text-success">₹0.00</span>
                                        </td>
                                        <td>
                                            <form method="post" action="return_book.jsp" style="display: inline;">
                                                <input type="hidden" name="transactionId" value="<%= transaction.getTransactionId() %>">
                                                <button type="submit" class="btn btn-success btn-sm" 
                                                        onclick="return confirm('Return this book?')">
                                                    <i class="fas fa-check"></i> Return
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    }
                                    
                                    // Show message if no books are issued
                                    if (issuedBooks.isEmpty() && overdueBooks.isEmpty()) {
                                    %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">
                                            <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                                            No books are currently issued
                                        </td>
                                    </tr>
                                    <%
                                    }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Statistics -->
        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h6><i class="fas fa-chart-pie"></i> Return Statistics</h6>
                    </div>
                    <div class="card-body">
                        <%
                        int totalIssued = issuedBooks.size();
                        int totalOverdue = overdueBooks.size();
                        double totalFines = 0.0;
                        
                        for (TransactionBean transaction : overdueBooks) {
                            java.util.Date today = new java.util.Date();
                            long daysDiff = (today.getTime() - transaction.getDueDate().getTime()) / (24 * 60 * 60 * 1000);
                            totalFines += daysDiff * 1.0;
                        }
                        %>
                        <div class="row text-center">
                            <div class="col-4">
                                <h4 class="text-primary"><%= totalIssued %></h4>
                                <small>Total Issued</small>
                            </div>
                            <div class="col-4">
                                <h4 class="text-danger"><%= totalOverdue %></h4>
                                <small>Overdue</small>
                            </div>
                            <div class="col-4">
                                <h4 class="text-warning">₹<%= String.format("%.2f", totalFines) %></h4>
                                <small>Pending Fines</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h6><i class="fas fa-info-circle"></i> Fine Policy</h6>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled mb-0">
                            <li><i class="fas fa-clock text-primary"></i> <strong>Loan Period:</strong> 14 days</li>
                            <li><i class="fas fa-rupee-sign text-warning"></i> <strong>Fine Rate:</strong> ₹1.00 per day</li>
                            <li><i class="fas fa-calendar-alt text-info"></i> <strong>Grace Period:</strong> None</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Debug function to check form submission
        function debugReturn(transactionId) {
            console.log('Attempting to return transaction ID:', transactionId);
            return true;
        }
        
        // Add debug to all forms
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form');
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    const transactionId = this.querySelector('input[name="transactionId"]').value;
                    console.log('Submitting transaction ID:', transactionId);
                });
            });
        });
    </script>
</body>
</html>
