<!DOCTYPE html>
<html lang="${config.site_locale.substring(0,2)}">
  <head>
    <meta charset="${config.site_encoding.toLowerCase()}">
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
    <title>${config.site_name}<%if (pagetitle) {%> - ${pagetitle}<%}%></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<%
        if (pagetitle) {
            out << "${config.site_name} : ${pagetitle}"
        } else {
            out << "${config.site_description}"
        }
    %>">
    <meta property="og:title" content="<%
        if (pagetitle) {
            out << "${config.site_name} - ${pagetitle}"
        } else {
            out << "${config.site_name}"
        }
    %>" />
    <meta property="og:type" content="website" />
    <meta property="og:image" content="${config.site_host}/img/${config.site_logo}" />
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
            out << "${config.site_name} : ${pagetitle}"
        } else {
            out << "${config.site_description}"
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
<% /*
    <link href="${contentRootPath}favicon.ico" rel="shortcut icon" >
*/ %>    
    <link href="data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAABILAAASCwAAAAAAAAAAAAD///8C////Av///wL///8C////Av///wL///8C////Av///wL///8C////Av///wL///8C////Av///wL///8C////Ff///xX///8V////Ff///xX///8V////Ff///xX///8V////Ff///xX///8V////Ff///xX///8V////Ff///y////8v////L////y////8v////L////y////8v////L////y////8v////L////y////8v////L////y////9J////Sf///0n///9J////Sf///0n///9J////Sf///0n///9J////Sf///0n///9J////Sf///0n///9J//+5Yv//uWL//7li//+5Yv//uWL//7li//+5Yv//uWL//7li//+5Yv//uWL//7li//+5Yv//uWL//7li//+5Yv+sYXz/rGF8/6xhfP+sYXz/rGF8/61ifP+vZX7/sWiA/7FogP+wZ3//rmN9/6xhfP+sYXz/rGF8/6xhfP+sYXzDZSaWxGYnl852O6HDeEa7pWE01Z1aLeacWSzwllUo9JZUJ/WbWCvynlos659cL921bj/GznxEqsdqLJjDZSaWkz4Fq6RUHrOvcEbhczoT/JRLGP6dWCj+rF0l/eaYYP3poGv9vW0z/ZZRIv2sXib9czQK/5VbNPG1bDzElD4Gq7RQDaW1UxClwmovtq1mNdSUUibrllIk9pRQIvqjYDD8ol0t/JRPIPuZVCT4klAj8Z9cLt++bjfCu1saqbRQDaXlbhyb5W4cm+VuHJvlbhyb5nAem+d1Jp/meS2k43kvqOJ5MKjleS6m53cpoedyIZ3lbxyb5W4cm+VuHJvlbhyb/5Askf+QLJH/kCyR/5Askf+QLJH/kCyR/5Askf2HNaL9hzSi/5Askf+QLJH/kCyR/5Askf+QLJH/kCyR/5Askf+3QIb/t0CG/7dAhv+3QIb/t0CG/7dAhv+3QIb/lz6i/5c+of+3QIb/t0CG/7dAhv+3QIb/t0CG/7dAhv+3QIb/51Z7/+dWe//nVnv/51Z7/+dWe//nVnv/51Z7/9FZif/RWor/51Z7/+dWe//nVnv/51Z7/+dWe//nVnv/51Z7//9ycf//cnH//3Jx//9ycf//cnH//3Jx//9ycf//cnH//3Jx//9ycf//cnH//3Jx//9ycf//cnH//3Jx//9ycf//k2j//5No//+TaP//k2j//5No//+TaP//k2j//5No//+TaP//k2j//5No//+TaP//k2j//5No//+TaP//k2j//7oy//+6Mv//ujL//7oy//+6Mv//ujL//7oy//+6Mv//ujL//7oy//+6Mv//ujL//7oy//+6Mv//ujL//7oyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==" rel="icon" type="image/x-icon">

    <link href="${contentRootPath}css/${config.bootswatch_style}<% if (config.bootswatch_style){%>/<%}else{%><%} %>bootstrap${config.lib_min}.css" rel="stylesheet" type="text/css">
    <link href="${contentRootPath}css/asciidoctor.css" rel="stylesheet" type="text/css">
    <link href="${contentRootPath}css/base.css" rel="stylesheet" type="text/css">

    <link href="${contentRootPath}css/font-awesome${config.lib_min}.css" rel="stylesheet" type="text/css">
    <link href="${contentRootPath}css/shCore${config.lib_min}.css" rel="stylesheet" type="text/css"/>
    <link href="${contentRootPath}css/shThemeDefault${config.lib_min}.css" rel="stylesheet" type="text/css"/>
    <!-- name collision with Bootsrapt class "container" -->
    <style>
       .syntaxhighlighter table .container:before {
            display: none !important;
       }
    </style>

    <!-- HTML5 shiv and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="${contentRootPath}js/html5shiv.js"></script>
      <script src="${contentRootPath}js/respond${config.lib_min}.js"></script>
    <![endif]-->

  </head>
  <body>
    <div id="wrap">
