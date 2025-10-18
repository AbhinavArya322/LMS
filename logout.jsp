<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Invalidate session and redirect to login
session.invalidate();
response.sendRedirect("login.jsp");
%>