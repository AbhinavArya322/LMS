<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Check if user is logged in
String headerUsername = (String) session.getAttribute("username");
String headerName = (String) session.getAttribute("name");
String headerRole = (String) session.getAttribute("role");

if (headerUsername == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">
            <i class="fas fa-book-open"></i>
            Library Management System
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <%
                if ("admin".equals(headerRole)) {
                %>
                <li class="nav-item">
                    <a class="nav-link" href="admin_dashboard.jsp">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="manage_books.jsp">
                        <i class="fas fa-book"></i> Manage Books
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="manage_members.jsp">
                        <i class="fas fa-users"></i> Manage Members
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="reports.jsp">
                        <i class="fas fa-chart-bar"></i> Reports
                    </a>
                </li>
                <%
                } else if ("librarian".equals(headerRole)) {
                %>
                <li class="nav-item">
                    <a class="nav-link" href="librarian_dashboard.jsp">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="add_book.jsp">
                        <i class="fas fa-book"></i> Add Books
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="issue_book.jsp">
                        <i class="fas fa-hand-point-right"></i> Issue Book
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="return_book.jsp">
                        <i class="fas fa-undo"></i> Return Book
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="add_member.jsp">
                        <i class="fas fa-user-plus"></i> Add Member
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="reports.jsp">
                        <i class="fas fa-chart-bar"></i> Reports
                    </a>
                </li>
                <%
                } else if ("member".equals(headerRole)) {
                %>
                <li class="nav-item">
                    <a class="nav-link" href="member_dashboard.jsp">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="search_books.jsp">
                        <i class="fas fa-search"></i> Search Books
                    </a>
                </li>
                <%
                }
                %>
            </ul>
            
            <ul class="navbar-nav">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user"></i> <%= headerName %> (<%= headerRole %>)
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="logout.jsp">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
