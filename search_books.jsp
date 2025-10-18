<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.BookBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Search Books</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <div class="container mt-4">
        <%
        String searchQuery = request.getParameter("search");
        List<BookBean> booksList = null;
        boolean hasSearched = false;
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            booksList = BookBean.searchBooks(searchQuery.trim());
            hasSearched = true;
        } else {
            booksList = BookBean.getAllBooks();
        }
        %>
        
        <h3 class="mb-4"><i class="fas fa-search"></i> Search Books</h3>
        
        <!-- Search Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="search_books.jsp">
                    <div class="input-group mb-3">
                        <input type="text" class="form-control form-control-lg" name="search" 
                               placeholder="Search by title, author, ISBN, or category..." 
                               value="<%= searchQuery != null ? searchQuery : "" %>">
                        <button type="submit" class="btn btn-primary btn-lg">
                            <i class="fas fa-search"></i> Search
                        </button>
                    </div>
                </form>
                
                <!-- Quick Category Buttons -->
                <div class="mb-2">
                    <strong>Quick Search:</strong>
                </div>
                <div>
                    <a href="?search=Programming" class="btn btn-outline-primary btn-sm me-1 mb-1">Programming</a>
                    <a href="?search=Database" class="btn btn-outline-primary btn-sm me-1 mb-1">Database</a>
                    <a href="?search=Java" class="btn btn-outline-primary btn-sm me-1 mb-1">Java</a>
                    <a href="?search=Web Development" class="btn btn-outline-primary btn-sm me-1 mb-1">Web Development</a>
                    <a href="?search=AI" class="btn btn-outline-primary btn-sm me-1 mb-1">AI/ML</a>
                    <a href="search_books.jsp" class="btn btn-outline-secondary btn-sm me-1 mb-1">Show All</a>
                </div>
                
                <!-- Results Info -->
                <div class="mt-3">
                    <% if (hasSearched) { %>
                    <div class="alert alert-info">
                        Found <strong><%= booksList.size() %></strong> book(s) matching "<%= searchQuery %>"
                    </div>
                    <% } else { %>
                    <div class="alert alert-secondary">
                        Showing all <strong><%= booksList.size() %></strong> books
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- Books Table -->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>Title</th>
                                <th>Author</th>
                                <th>Category</th>
                                <th>Year</th>
                                <th>Copies</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            if (booksList == null || booksList.isEmpty()) {
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">
                                    <% if (hasSearched) { %>
                                    <i class="fas fa-search fa-2x mb-2 d-block"></i>
                                    No books found matching "<%= searchQuery %>"
                                    <% } else { %>
                                    <i class="fas fa-book fa-2x mb-2 d-block"></i>
                                    No books available
                                    <% } %>
                                </td>
                            </tr>
                            <%
                            } else {
                                for (BookBean book : booksList) {
                            %>
                            <tr>
                                <td>
                                    <strong class="text-primary"><%= book.getTitle() %></strong>
                                    <% if (book.getPublisher() != null && !book.getPublisher().trim().isEmpty()) { %>
                                    <br><small class="text-muted"><%= book.getPublisher() %></small>
                                    <% } %>
                                </td>
                                <td><%= book.getAuthor() %></td>
                                <td>
                                    <span class="badge bg-secondary">
                                        <%= book.getCategory() != null ? book.getCategory() : "General" %>
                                    </span>
                                </td>
                                <td><%= book.getPublicationYear() > 0 ? book.getPublicationYear() : "N/A" %></td>
                                <td>
                                    <span class="badge bg-primary"><%= book.getTotalCopies() %></span>
                                    <span class="text-muted">(<%= book.getAvailableCopies() %> available)</span>
                                </td>
                                <td>
                                    <% if (book.getAvailableCopies() > 0) { %>
                                    <span class="badge bg-success"><i class="fas fa-check"></i> Available</span>
                                    <% } else { %>
                                    <span class="badge bg-danger"><i class="fas fa-times"></i> Out of Stock</span>
                                    <% } %>
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
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Auto-focus search input
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.querySelector('input[name="search"]');
            if (searchInput && !searchInput.value) {
                searchInput.focus();
            }
        });
    </script>
</body>
</html>
