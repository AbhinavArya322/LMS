<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.library.beans.AuthenticationBean" %>

<%
String username = request.getParameter("username");
String password = request.getParameter("password");

AuthenticationBean authBean = new AuthenticationBean(username, password);

if (authBean.authenticate()) {
    // Store user information in session
    session.setAttribute("user", authBean);
    session.setAttribute("username", authBean.getUsername());
    session.setAttribute("name", authBean.getName());
    session.setAttribute("role", authBean.getRole());
    session.setAttribute("userId", authBean.getUserId());
    
    // Redirect based on role
    String role = authBean.getRole();
    if ("admin".equals(role)) {
        response.sendRedirect("admin_dashboard.jsp");
    } else if ("librarian".equals(role)) {
        response.sendRedirect("librarian_dashboard.jsp");
    } else if ("member".equals(role)) {
        response.sendRedirect("member_dashboard.jsp");
    } else {
        response.sendRedirect("login.jsp?error=true");
    }
} else {
    response.sendRedirect("login.jsp?error=true");
}
%>