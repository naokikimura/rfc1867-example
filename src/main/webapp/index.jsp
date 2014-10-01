<!DOCTYPE HTML>
<%@page contentType="text/html" pageEncoding="UTF-8" import="java.util.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.io.IOUtils" %>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title>use Servlet 3.0</title>
</head>
<body>
    <h2>Hello World!</h2>
<%
List<String> fields = Arrays.asList("title", "message");
String method = request.getMethod();
String contentType = request.getContentType();
boolean isMultipartContent = "POST".equalsIgnoreCase(method) && contentType != null && contentType.toLowerCase(Locale.ENGLISH).startsWith("multipart/");

if (isMultipartContent) {
    Collection<Part> parts = request.getParts();
    for (Part part : parts) {
        if (!fields.contains(part.getName())) continue;

        application.log("part=" + part);
        application.log(String.format("{ Name: %s, Content-Type: %s, Size: %d }", part.getName(), part.getContentType(), part.getSize()));
        pageContext.setAttribute(part.getName(), IOUtils.toString(part.getInputStream(), "UTF-8"));
    }
} else {
    if (!"GET".equalsIgnoreCase(request.getMethod())) response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Content-Type != multipart/form-data");

    for (String field : fields) pageContext.setAttribute(field, request.getParameter(field));
}
%>
    <ul>
        <li><a href="./index.jsp">use Servlet 3.0</a></li>
        <li><a href="./commons-fileupload.jsp">use Apache Commons FileUpload</a></li>
    </ul>
    <dl>
        <dt>title</dt>
        <dd><pre><code>${title}</code></pre></dd>
        <dt>message</dt>
        <dd><pre><code>${message}</code></pre></dd>
    </dl>
    <form action="" method="post" enctype="multipart/form-data">
        <label for="title">Title</label>
        <input type="text" name="title" id="title" />
        <label for="message">Message</label>
        <input type="file" name="message" id="message" />
        <input type="submit" />
    </form>
</body>
</html>
