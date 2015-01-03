<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8">
    <%
        def pagetitle = null
        if (content.title) {
            pagetitle = content.title
        } else if (content.type == "tag") {
            pagetitle = "${tag}"

        } else if (content.type == "archive") {
            pagetitle = "Archives"
        }
    %>
    <title>Pop Tech<%if (pagetitle) {%> - ${pagetitle}<%}%></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<%
        if (pagetitle) {
            out << "Pop Tech : ${pagetitle}"
        } else {
            out << "Pop Tech : partager un rex perso. Très touche à tout : Linux, Java, Maven, Eclipse..."
        }
    %>">
    <meta property="og:title" content="<%
        if (pagetitle) {
            out << "Pop Tech - ${pagetitle}"
        } else {
            out << "Pop Tech"
        }
    %>" />
    <meta property="og:type" content="website" />
    <meta property="og:image" content="${config.site_host}/img/poptech.png" />
    <meta property="og:url" content="<%
        if (content.type == "archive") {
            out << """${config.site_host}/archive.html"""
        } else if (content.type == "tag") {
            out << """${config.site_host}/tags/${tag}.html"""
        } else {
            out << config.site_host
        }
    %>" />
    <meta property="og:description" content="<%
        if (pagetitle) {
            out << "Pop Tech : ${pagetitle}"
        } else {
            out << "Pop Tech : partager un rex perso. Très touche à tout : Linux, Java, Maven, Eclipse..."
        }
    %>" />
    <meta property="og:locale" content="${config.site_locale}" />
    <meta property="og:site_name" content="${config.site_name}" />

    <!-- Styles -->
    <%
        def contentRootPath = ""
        if (content.rootpath) {
            contentRootPath = content.rootpath
        }
        else if (content.type == "tag"){
            contentRootPath =  "../"
        }
    %>
    <link href="${contentRootPath}favicon.ico" rel="shortcut icon" >

    <link href="${contentRootPath}css/${config.bootswatch_style}<% if (config.bootswatch_style){%>/<%}else{%><%} %>bootstrap.min.css" rel="stylesheet" type="text/css">
    <link href="${contentRootPath}css/base.css" rel="stylesheet" type="text/css">
    <link href="${contentRootPath}css/asciidoctor.css" rel="stylesheet" type="text/css">

    <link href="${contentRootPath}css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href="${contentRootPath}css/shCore.css" rel="stylesheet" type="text/css"/>
    <link href="${contentRootPath}css/shThemeDefault.css" rel="stylesheet" type="text/css"/>

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="${contentRootPath}js/html5shiv.js"></script>
      <script src="${contentRootPath}js/respond.min.js"></script>
    <![endif]-->

  </head>
  <body>
    <div id="wrap">
