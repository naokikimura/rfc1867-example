<!DOCTYPE HTML>
<%@page contentType="text/html;charset=UTF-8" import="java.util.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.io.IOUtils" %>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title>Index</title>
</head>
<body>
    <h2>Hello World!</h2>
<%
List<String> fields = Arrays.asList("title", "message");

boolean isMultipartContent = ServletFileUpload.isMultipartContent(request);
request.setAttribute("org.apache.commons.fileupload.servlet.ServletFileUpload.isMultipartContent", isMultipartContent);

if (isMultipartContent) {
    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setRepository((java.io.File) application.getAttribute("javax.servlet.context.tempdir"));
    ServletFileUpload upload = new ServletFileUpload(factory);
    Map<String, List<FileItem>> parameterMap = upload.parseParameterMap(request);
    request.setAttribute("org.apache.commons.fileupload.servlet.ServletFileUpload.parseParameterMap", parameterMap);

    Map<String, List<FileItem>> parameters = (Map<String, List<FileItem>>) request.getAttribute("org.apache.commons.fileupload.servlet.ServletFileUpload.parseParameterMap");
    for (String field : fields) {
        if (!parameters.containsKey(field)) continue;

        for (FileItem item : parameters.get(field)) {
            if (item.isFormField()) {
                pageContext.setAttribute(item.getFieldName(), item.getString());
            } else {
                try (java.io.InputStream is = item.getInputStream();) {
                    pageContext.setAttribute(item.getFieldName(), IOUtils.toString(is, "UTF-8"));
                }
            }
        }
    }
} else {
    for (String field : fields) pageContext.setAttribute(field, request.getParameter(field));
}
%>
    <dl>
        <dt>isMultipartContent</dt>
        <dd><code>${requestScope['org.apache.commons.fileupload.servlet.ServletFileUpload.isMultipartContent']}</code></dd>
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
