<!DOCTYPE HTML>
<%@page contentType="text/html" pageEncoding="UTF-8" import="java.util.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.io.IOUtils" %>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title>Index</title>
</head>
<body>
    <h2>Hello World!</h2>
<%
boolean useCommonsFileupload = Boolean.parseBoolean(System.getProperty("example.useCommonsFileupload", "false"));
application.log("example.useCommonsFileupload=" + useCommonsFileupload);

String method = request.getMethod();
String contentType = request.getContentType();
boolean isMultipartContent = "POST".equalsIgnoreCase(method) && contentType != null && contentType.toLowerCase(Locale.ENGLISH).startsWith("multipart/");
request.setAttribute("org.apache.commons.fileupload.servlet.ServletFileUpload.isMultipartContent", Boolean.valueOf(isMultipartContent));

if (isMultipartContent) {
    try {
        Collection<Part> parts = request.getParts();
        request.setAttribute("javax.servlet.http.HttpServletRequest.getParts", parts);
    } catch (RuntimeException e) {
        application.log("parts is null", e);
    }

    if (useCommonsFileupload || request.getAttribute("javax.servlet.http.HttpServletRequest.getParts") == null) {
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setRepository((java.io.File) application.getAttribute("javax.servlet.context.tempdir"));
        ServletFileUpload upload = new ServletFileUpload(factory);
        Map<String, List<FileItem>> parameterMap = upload.parseParameterMap(request);
        request.setAttribute("org.apache.commons.fileupload.servlet.ServletFileUpload.parseParameterMap", parameterMap);
    }
}

List<String> fields = Arrays.asList("title", "message");
if ((Boolean) request.getAttribute("org.apache.commons.fileupload.servlet.ServletFileUpload.isMultipartContent")) {
    Collection<Part> parts = (Collection<Part>) request.getAttribute("javax.servlet.http.HttpServletRequest.getParts");
    if (parts == null) {
        Map<String, List<FileItem>> parameterMap = (Map<String, List<FileItem>>) request.getAttribute("org.apache.commons.fileupload.servlet.ServletFileUpload.parseParameterMap");
        for (String field : fields) {
            if (!parameterMap.containsKey(field)) continue;

            for (FileItem item : parameterMap.get(field)) {
                application.log("item=" + item);
                application.log(String.format("{ Name: %s, Content-Type: %s, Size: %d }", item.getFieldName(), item.getContentType(), item.getSize()));
                if (item.isFormField()) {
                    pageContext.setAttribute(item.getFieldName(), item.getString());
                } else {
                    pageContext.setAttribute(item.getFieldName(), IOUtils.toString(item.getInputStream(), "UTF-8"));
                }
            }
        }
    } else {
        for (Part part : parts) {
            if (!fields.contains(part.getName())) continue;
            
            application.log("part=" + part);
            application.log(String.format("{ Name: %s, Content-Type: %s, Size: %d }", part.getName(), part.getContentType(), part.getSize()));
            pageContext.setAttribute(part.getName(), IOUtils.toString(part.getInputStream(), "UTF-8"));
        }
    }
} else {
    for (String field : fields) pageContext.setAttribute(field, request.getParameter(field));
}
%>
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
