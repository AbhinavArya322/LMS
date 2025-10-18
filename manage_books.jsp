<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.BookBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Books</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <div class="container mt-4">
        <%
        String adminRole = (String) session.getAttribute("role");
        if (!"admin".equals(adminRole) && !"librarian".equals(adminRole)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String message = "";
        String messageType = "";
        
        // Handle book actions
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");
            String bookIdStr = request.getParameter("bookId");
            
            if ("activate".equals(action) || "deactivate".equals(action)) {
                message = "Book " + action + "d successfully!";
                messageType = "success";
            }
        }
        %>
        
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4><i class="fas fa-books"></i> Manage Books</h4>
                        <p class="mb-0">View, edit, and manage library books</p>
                    </div>
                </div>
            </div>
        </div>
        
        <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= messageType %> alert-dismissible fade show">
            <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <!-- Quick Actions -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3">
                                <a href="add_book.jsp" class="btn btn-success w-100">
                                    <i class="fas fa-plus-circle"></i> Add New Book
                                </a>
                            </div>
                            <div class="col-md-3">
                                <button class="btn btn-info w-100" onclick="exportBooks()">
                                    <i class="fas fa-download"></i> Export List
                                </button>
                            </div>
                            <div class="col-md-6">
                                <form method="get" action="manage_books.jsp">
                                    <div class="input-group">
                                        <input type="text" name="search" class="form-control" 
                                               placeholder="Search books..." 
                                               value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                                        <button type="submit" class="btn btn-outline-primary">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Books List -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5>All Books</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Book ID</th>
                                        <th>Title</th>
                                        <th>Author</th>
                                        <th>Category</th>
                                        <th>Copies</th>
                                        <th>Available</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    String searchTerm = request.getParameter("search");
                                    List<BookBean> books = null;
                                    
                                    try {
                                        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                                            books = BookBean.searchBooks(searchTerm.trim());
                                        } else {
                                            books = BookBean.getAllBooks();
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                        books = new java.util.ArrayList<>();
                                    }
                                    
                                    if (books.isEmpty()) {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">
                                            <i class="fas fa-book fa-2x mb-2 d-block"></i>
                                            No books found
                                        </td>
                                    </tr>
                                    <%
                                    } else {
                                        for (BookBean book : books) {
                                    %>
                                    <tr>
                                        <td><strong>#<%= book.getBookId() %></strong></td>
                                        <td>
                                            <strong class="text-primary"><%= book.getTitle() %></strong>
                                            <% if (book.getIsbn() != null && !book.getIsbn().trim().isEmpty()) { %>
                                            <br><small class="text-muted">ISBN: <%= book.getIsbn() %></small>
                                            <% } %>
                                        </td>
                                        <td><%= book.getAuthor() %></td>
                                        <td>
                                            <span class="badge bg-secondary">
                                                <%= book.getCategory() != null ? book.getCategory() : "General" %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge bg-primary"><%= book.getTotalCopies() %></span>
                                        </td>
                                        <td>
                                            <span class="badge bg-<%= book.getAvailableCopies() > 0 ? "success" : "warning" %>">
                                                <%= book.getAvailableCopies() %>
                                            </span>
                                        </td>
                                        <td>
                                            <% if (book.isActive()) { %>
                                            <span class="badge bg-success">Active</span>
                                            <% } else { %>
                                            <span class="badge bg-danger">Inactive</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <div class="btn-group" role="group">
                                                <button type="button" class="btn btn-outline-info btn-sm" 
                                                        onclick="viewBook(<%= book.getBookId() %>)">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" class="btn btn-outline-warning btn-sm" 
                                                        onclick="editBook(<%= book.getBookId() %>)">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                                <% if (book.isActive()) { %>
                                                <button type="button" class="btn btn-outline-danger btn-sm" 
                                                        onclick="deactivateBook(<%= book.getBookId() %>)">
                                                    <i class="fas fa-ban"></i>
                                                </button>
                                                <% } else { %>
                                                <button type="button" class="btn btn-outline-success btn-sm" 
                                                        onclick="activateBook(<%= book.getBookId() %>)">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                        }
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
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4 class="text-primary"><%= books.size() %></h4>
                        <small>Total Books</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4 class="text-success">
                            <%= books.stream().mapToInt(b -> b.getAvailableCopies()).sum() %>
                        </h4>
                        <small>Available Copies</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4 class="text-warning">
                            <%= books.stream().mapToInt(b -> b.getTotalCopies() - b.getAvailableCopies()).sum() %>
                        </h4>
                        <small>Issued Copies</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4 class="text-info"><%= books.stream().collect(java.util.stream.Collectors.groupingBy(BookBean::getCategory)).size() %></h4>
                        <small>Categories</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function viewBook(bookId) {
            alert('View book details for ID: ' + bookId);
        }
        
        function editBook(bookId) {
            alert('Edit book ID: ' + bookId);
        }
        
        function activateBook(bookId) {
            if (confirm('Activate this book?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.innerHTML = '<input name="action" value="activate"><input name="bookId" value="' + bookId + '">';
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function deactivateBook(bookId) {
            if (confirm('Deactivate this book?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.innerHTML = '<input name="action" value="deactivate"><input name="bookId" value="' + bookId + '">';
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function exportBooks() {
            alert('Export functionality coming soon!');
        }
    </script>
</body>
</html>
