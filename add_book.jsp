<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.BookBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Book - Library Management System</title>
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
        .btn-submit {
            background: linear-gradient(135deg, #2E8B57, #20B2AA);
            border: none;
            color: white;
            padding: 12px 30px;
            border-radius: 8px;
        }
        .btn-submit:hover {
            background: linear-gradient(135deg, #20B2AA, #2E8B57);
            color: white;
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    
    <div class="container mt-4">
        <%
        String message = "";
        String messageType = "";
        
        if ("POST".equals(request.getMethod())) {
            String title = request.getParameter("title");
            String author = request.getParameter("author");
            String isbn = request.getParameter("isbn");
            String publisher = request.getParameter("publisher");
            String category = request.getParameter("category");
            String publicationYearStr = request.getParameter("publicationYear");
            String totalCopiesStr = request.getParameter("totalCopies");
            String priceStr = request.getParameter("price");
            
            try {
                int publicationYear = Integer.parseInt(publicationYearStr);
                int totalCopies = Integer.parseInt(totalCopiesStr);
                double price = Double.parseDouble(priceStr);
                
                BookBean book = new BookBean(title, author, isbn, publisher, category, publicationYear, totalCopies, price);
                
                if (book.addBook()) {
                    message = "Book added successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to add book. Please try again.";
                    messageType = "danger";
                }
            } catch (NumberFormatException e) {
                message = "Please enter valid numeric values.";
                messageType = "danger";
            }
        }
        %>
        
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="form-card">
                    <div class="form-header">
                        <h3><i class="fas fa-plus-circle"></i> Add New Book</h3>
                        <p class="mb-0">Enter book details to add to the library collection</p>
                    </div>
                    
                    <% if (!message.isEmpty()) { %>
                    <div class="alert alert-<%= messageType %>" role="alert">
                        <i class="fas fa-<%= messageType.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
                        <%= message %>
                    </div>
                    <% } %>
                    
                    <form method="post" action="add_book.jsp">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="title" class="form-label">Book Title *</label>
                                <input type="text" class="form-control" id="title" name="title" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="author" class="form-label">Author *</label>
                                <input type="text" class="form-control" id="author" name="author" required>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="isbn" class="form-label">ISBN</label>
                                <input type="text" class="form-control" id="isbn" name="isbn" placeholder="978-XXXXXXXXXX">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="publisher" class="form-label">Publisher</label>
                                <input type="text" class="form-control" id="publisher" name="publisher">
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="category" class="form-label">Category *</label>
                                <select class="form-select" id="category" name="category" required>
                                    <option value="">Select Category</option>
                                    <option value="Programming">Programming</option>
                                    <option value="Computer Science">Computer Science</option>
                                    <option value="Database">Database</option>
                                    <option value="AI/ML">AI/ML</option>
                                    <option value="Web Development">Web Development</option>
                                    <option value="Mobile Development">Mobile Development</option>
                                    <option value="Data Science">Data Science</option>
                                    <option value="Networking">Networking</option>
                                    <option value="Operating Systems">Operating Systems</option>
                                    <option value="Software Engineering">Software Engineering</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="publicationYear" class="form-label">Publication Year</label>
                                <input type="number" class="form-control" id="publicationYear" name="publicationYear" min="1900" max="2025">
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="totalCopies" class="form-label">Total Copies *</label>
                                <input type="number" class="form-control" id="totalCopies" name="totalCopies" min="1" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="price" class="form-label">Price (₹)</label>
                                <input type="number" class="form-control" id="price" name="price" step="0.01" min="0">
                            </div>
                        </div>
                        
                        <div class="text-center">
                            <button type="submit" class="btn btn-submit me-3">
                                <i class="fas fa-save"></i> Add Book
                            </button>
                            <a href="librarian_dashboard.jsp" class="btn btn-secondary">
                                <i class="fas fa-times"></i> Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        
        <!-- Recently Added Books -->
        <div class="row">
            <div class="col-12">
                <div class="form-card">
                    <div class="form-header">
                        <h4><i class="fas fa-clock"></i> Recently Added Books</h4>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Author</th>
                                    <th>Category</th>
                                    <th>Copies</th>
                                    <th>Date Added</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                List<BookBean> recentBooks = BookBean.getAllBooks();
                                int count = 0;
                                for (BookBean book : recentBooks) {
                                    if (count >= 10) break; // Show only 10 recent books
                                %>
                                <tr>
                                    <td><%= book.getTitle() %></td>
                                    <td><%= book.getAuthor() %></td>
                                    <td><%= book.getCategory() %></td>
                                    <td>
                                        <span class="badge bg-primary"><%= book.getTotalCopies() %></span>
                                        <small class="text-muted">(<%= book.getAvailableCopies() %> available)</small>
                                    </td>
                                    <td><%= book.getDateAdded() != null ? book.getDateAdded().toString().substring(0, 10) : "N/A" %></td>
                                </tr>
                                <%
                                    count++;
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