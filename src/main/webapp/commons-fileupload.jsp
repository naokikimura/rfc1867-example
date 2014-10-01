<!DOCTYPE HTML>
<%@page contentType="text/html" pageEncoding="UTF-8" import="java.util.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.io.IOUtils" %>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title>use Apache Commons FileUpload</title>
</head>
<body>
    <h2>Hello World!</h2>
<%
List<String> fields = Arrays.asList("title", "message");
boolean isMultipartContent = ServletFileUpload.isMultipartContent(request);

if (isMultipartContent) {
    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setRepository((java.io.File) application.getAttribute("javax.servlet.context.tempdir"));
    ServletFileUpload upload = new ServletFileUpload(factory);
    Map<String, List<FileItem>> parameterMap = upload.parseParameterMap(request);
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
    if (!"GET".equalsIgnoreCase(request.getMethod())) response.sendError(HttpServletResponse.SC_BAD_REQUEST);

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
