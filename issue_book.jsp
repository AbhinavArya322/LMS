<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.BookBean, com.library.beans.MemberBean, com.library.beans.TransactionBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Issue Book</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <div class="container mt-4">
        <%
        String message = "";
        String messageType = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            try {
                String bookIdStr = request.getParameter("bookId");
                String memberIdStr = request.getParameter("memberId");
                Integer librarianId = (Integer) session.getAttribute("userId");
                
                if (bookIdStr != null && memberIdStr != null && librarianId != null) {
                    int bookId = Integer.parseInt(bookIdStr);
                    int memberId = Integer.parseInt(memberIdStr);
                    
                    TransactionBean transaction = new TransactionBean(bookId, memberId, librarianId);
                    
                    if (transaction.issueBook()) {
                        message = "Book issued successfully!";
                        messageType = "success";
                    } else {
                        message = "Failed to issue book. Book may not be available or member has reached limit.";
                        messageType = "danger";
                    }
                } else {
                    message = "Please select both book and member.";
                    messageType = "danger";
                }
            } catch (NumberFormatException e) {
                message = "Invalid book or member selection.";
                messageType = "danger";
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "danger";
            }
        }
        %>
        
        <h3 class="mb-4"><i class="fas fa-hand-point-right"></i> Issue Book</h3>
        
        <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= messageType %> alert-dismissible fade show">
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5>Issue Book to Member</h5>
                    </div>
                    <div class="card-body">
                        <form method="post" action="issue_book.jsp">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Select Book *</label>
                                    <select name="bookId" class="form-select" required>
                                        <option value="">Choose a book...</option>
                                        <%
                                        List<BookBean> availableBooks = BookBean.getAvailableBooks();
                                        for (BookBean book : availableBooks) {
                                        %>
                                        <option value="<%= book.getBookId() %>">
                                            <%= book.getTitle() %> by <%= book.getAuthor() %> 
                                            (<%= book.getAvailableCopies() %> available)
                                        </option>
                                        <%
                                        }
                                        %>
                                    </select>
                                </div>
                                
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Select Member *</label>
                                    <select name="memberId" class="form-select" required>
                                        <option value="">Choose a member...</option>
                                        <%
                                        List<MemberBean> members = MemberBean.getAllMembers();
                                        for (MemberBean member : members) {
                                        %>
                                        <option value="<%= member.getUserId() %>">
                                            <%= member.getName() %> (<%= member.getUsername() %>)
                                        </option>
                                        <%
                                        }
                                        %>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="text-center">
                                <button type="submit" class="btn btn-primary me-2">
                                    <i class="fas fa-check"></i> Issue Book
                                </button>
                                <a href="librarian_dashboard.jsp" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Back
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h6>Issue Guidelines</h6>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled small">
                            <li><i class="fas fa-check text-success"></i> Maximum 3 books per member</li>
                            <li><i class="fas fa-check text-success"></i> 14 days loan period</li>
                            <li><i class="fas fa-check text-success"></i> ₹1 fine per day for overdue</li>
                            <li><i class="fas fa-check text-success"></i> Book must be available</li>
                        </ul>
                    </div>
                </div>
                
                <div class="card mt-3">
                    <div class="card-header">
                        <h6>Quick Stats</h6>
                    </div>
                    <div class="card-body text-center">
                        <div class="row">
                            <div class="col-6">
                                <h5 class="text-primary"><%= BookBean.getAvailableBooks().size() %></h5>
                                <small>Available Books</small>
                            </div>
                            <div class="col-6">
                                <h5 class="text-success"><%= MemberBean.getAllMembers().size() %></h5>
                                <small>Active Members</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Currently Issued Books -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-list"></i> Recently Issued Books</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Book</th>
                                        <th>Member</th>
                                        <th>Issue Date</th>
                                        <th>Due Date</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    List<TransactionBean> issuedBooks = TransactionBean.getIssuedBooks();
                                    int count = 0;
                                    for (TransactionBean transaction : issuedBooks) {
                                        if (count >= 10) break; // Show only last 10
                                        
                                        java.util.Date today = new java.util.Date();
                                        boolean isOverdue = today.after(transaction.getDueDate());
                                    %>
                                    <tr>
                                        <td>
                                            <strong><%= transaction.getBookTitle() %></strong><br>
                                            <small class="text-muted">by <%= transaction.getBookAuthor() %></small>
                                        </td>
                                        <td><%= transaction.getMemberName() %></td>
                                        <td><%= transaction.getIssueDate() %></td>
                                        <td><%= transaction.getDueDate() %></td>
                                        <td>
                                            <span class="badge bg-<%= isOverdue ? "danger" : "success" %>">
                                                <%= isOverdue ? "OVERDUE" : "ACTIVE" %>
                                            </span>
                                        </td>
                                    </tr>
                                    <%
                                        count++;
                                    }
                                    
                                    if (issuedBooks.isEmpty()) {
                                    %>
                                    <tr>
                                        <td colspan="5" class="text-center text-muted">No books currently issued</td>
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
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
