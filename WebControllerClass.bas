﻿B4J=true
Group=Controllers
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
' Web Controller
' Version 1.08
Sub Class_Globals
	Private Request As ServletRequest 'ignore
	Private Response As ServletResponse
End Sub

Public Sub Initialize (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
End Sub

Public Sub ShowPage
	Dim strMain As String = WebApiUtils.ReadTextFile("main.html")
	Dim strView As String = WebApiUtils.ReadTextFile("index.html")
	Dim strHelp As String
	Dim strJSFile As String
	Dim strScripts As String
	
	If Main.SHOW_API_ICON Then
		strHelp = $"        <li class="nav-item">
          <a class="nav-link mr-3 font-weight-bold text-white" href="${Main.Config.Get("ROOT_URL")}${Main.Config.Get("ROOT_PATH")}help"><i class="fas fa-cog" title="API"></i> API</a>
	</li>"$
	Else
		strHelp = ""
	End If
	
	strMain = WebApiUtils.BuildDocView(strMain, strView)
	strMain = WebApiUtils.BuildTag(strMain, "HELP", strHelp)
	strMain = WebApiUtils.BuildHtml(strMain, Main.Config)
	If Main.SimpleResponse.Enable Then
		If Main.SimpleResponse.Format = "Map" Then
			strJSFile = "webapi.search.simple.map.js"
		Else
			strJSFile = "webapi.search.simple.js"
		End If
	Else
		strJSFile = "webapi.search.js"
	End If
	strScripts = $"<script src="${Main.Config.Get("ROOT_URL")}/assets/js/${strJSFile}"></script>"$
	strMain = WebApiUtils.BuildScript(strMain, strScripts)
	WebApiUtils.ReturnHTML(strMain, Response)
End Sub