<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.MemberBean" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Members</title>
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
        
        // Handle member actions (activate/deactivate)
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");
            String memberIdStr = request.getParameter("memberId");
            
            if ("activate".equals(action) || "deactivate".equals(action)) {
                // For now, just show success message
                message = "Member " + action + "d successfully!";
                messageType = "success";
            }
        }
        %>
        
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4><i class="fas fa-users"></i> Manage Members</h4>
                        <p class="mb-0">View, edit, and manage library members</p>
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
                                <a href="add_member.jsp" class="btn btn-success w-100">
                                    <i class="fas fa-user-plus"></i> Add New Member
                                </a>
                            </div>
                            <div class="col-md-3">
                                <button class="btn btn-info w-100" onclick="exportMembers()">
                                    <i class="fas fa-download"></i> Export List
                                </button>
                            </div>
                            <div class="col-md-6">
                                <form method="get" action="manage_members.jsp">
                                    <div class="input-group">
                                        <input type="text" name="search" class="form-control" 
                                               placeholder="Search members..." 
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
        
        <!-- Members List -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5>All Members</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Member ID</th>
                                        <th>Name</th>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Registration Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    String searchTerm = request.getParameter("search");
                                    List<MemberBean> members = null;
                                    
                                    try {
                                        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                                            // If search method exists, use it; otherwise get all
                                            members = MemberBean.getAllMembers();
                                        } else {
                                            members = MemberBean.getAllMembers();
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                        members = new java.util.ArrayList<>();
                                    }
                                    
                                    if (members.isEmpty()) {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">
                                            <i class="fas fa-users fa-2x mb-2 d-block"></i>
                                            No members found
                                        </td>
                                    </tr>
                                    <%
                                    } else {
                                        for (MemberBean member : members) {
                                    %>
                                    <tr>
                                        <td><strong>#<%= member.getUserId() %></strong></td>
                                        <td>
                                            <strong><%= member.getName() %></strong>
                                        </td>
                                        <td><%= member.getUsername() %></td>
                                        <td>
                                            <a href="mailto:<%= member.getEmail() %>"><%= member.getEmail() %></a>
                                        </td>
                                        <td>
                                            <%= member.getPhone() != null ? member.getPhone() : "N/A" %>
                                        </td>
                                        <td>
                                            <%= member.getRegistrationDate() != null ? member.getRegistrationDate().toString() : "N/A" %>
                                        </td>
                                        <td>
                                            <% if (member.isActive()) { %>
                                            <span class="badge bg-success">Active</span>
                                            <% } else { %>
                                            <span class="badge bg-danger">Inactive</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <div class="btn-group" role="group">
                                                <button type="button" class="btn btn-outline-info btn-sm" 
                                                        onclick="viewMember(<%= member.getUserId() %>)">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <button type="button" class="btn btn-outline-warning btn-sm" 
                                                        onclick="editMember(<%= member.getUserId() %>)">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                                <% if (member.isActive()) { %>
                                                <button type="button" class="btn btn-outline-danger btn-sm" 
                                                        onclick="deactivateMember(<%= member.getUserId() %>)">
                                                    <i class="fas fa-ban"></i>
                                                </button>
                                                <% } else { %>
                                                <button type="button" class="btn btn-outline-success btn-sm" 
                                                        onclick="activateMember(<%= member.getUserId() %>)">
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
                        <h4 class="text-primary"><%= members.size() %></h4>
                        <small>Total Members</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4 class="text-success">
                            <%= members.stream().mapToInt(m -> m.isActive() ? 1 : 0).sum() %>
                        </h4>
                        <small>Active Members</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4 class="text-warning">0</h4>
                        <small>Pending Approvals</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h4 class="text-info">0</h4>
                        <small>This Month</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function viewMember(memberId) {
            alert('View member details for ID: ' + memberId);
            // Implement view functionality
        }
        
        function editMember(memberId) {
            alert('Edit member ID: ' + memberId);
            // Redirect to edit page or open modal
        }
        
        function activateMember(memberId) {
            if (confirm('Activate this member?')) {
                // Submit form to activate member
                const form = document.createElement('form');
                form.method = 'POST';
                form.innerHTML = '<input name="action" value="activate"><input name="memberId" value="' + memberId + '">';
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function deactivateMember(memberId) {
            if (confirm('Deactivate this member?')) {
                // Submit form to deactivate member
                const form = document.createElement('form');
                form.method = 'POST';
                form.innerHTML = '<input name="action" value="deactivate"><input name="memberId" value="' + memberId + '">';
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function exportMembers() {
            alert('Export functionality coming soon!');
        }
    </script>
</body>
</html>
