<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.MemberBean" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Member - Library Management System</title>
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

if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
        String memberUsername = request.getParameter("username");
        String memberPassword = request.getParameter("password");
        String memberName = request.getParameter("name");
        String memberEmail = request.getParameter("email");
        String memberPhone = request.getParameter("phone");
        String memberAddress = request.getParameter("address");
        
        if (memberUsername != null && memberPassword != null && memberName != null && memberEmail != null) {
            MemberBean member = new MemberBean();
            member.setUsername(memberUsername);
            member.setPassword(memberPassword);
            member.setName(memberName);
            member.setEmail(memberEmail);
            if (memberPhone != null) member.setPhone(memberPhone);
            if (memberAddress != null) member.setAddress(memberAddress);
            
            if (member.addMember()) {
                message = "Member added successfully!";
                messageType = "success";
            } else {
                message = "Failed to add member. Username or email may already exist.";
                messageType = "danger";
            }
        } else {
            message = "Username, password, name and email are required.";
            messageType = "danger";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        messageType = "danger";
    }
}
%>

        
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="form-card">
                    <div class="form-header">
                        <h3><i class="fas fa-user-plus"></i> Add New Member</h3>
                        <p class="mb-0">Register a new library member</p>
                    </div>
                    
                    <% if (!message.isEmpty()) { %>
                    <div class="alert alert-<%= messageType %>" role="alert">
                        <i class="fas fa-<%= messageType.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
                        <%= message %>
                    </div>
                    <% } %>
                    
                    <form method="post" action="add_member.jsp">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="username" class="form-label">Username *</label>
                                <input type="text" class="form-control" id="username" name="username" required>
                                <small class="form-text text-muted">Must be unique</small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="password" class="form-label">Password *</label>
                                <input type="password" class="form-control" id="password" name="password" required minlength="6">
                                <small class="form-text text-muted">Minimum 6 characters</small>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="name" class="form-label">Full Name *</label>
                            <input type="text" class="form-control" id="name" name="name" required>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label">Email Address *</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="phone" name="phone" pattern="[0-9]{10}">
                                <small class="form-text text-muted">10 digits only</small>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="address" class="form-label">Address</label>
                            <textarea class="form-control" id="address" name="address" rows="3" placeholder="Full address"></textarea>
                        </div>
                        
                        <div class="text-center">
                            <button type="submit" class="btn btn-submit me-3">
                                <i class="fas fa-save"></i> Add Member
                            </button>
                            <a href="librarian_dashboard.jsp" class="btn btn-secondary">
                                <i class="fas fa-times"></i> Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
